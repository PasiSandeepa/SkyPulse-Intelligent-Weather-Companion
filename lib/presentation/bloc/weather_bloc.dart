import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/ip_location_service.dart';
import '../../domain/usecases/get_forecast_usecase.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class _ResolvedCoordinates {
  final double latitude;
  final double longitude;
  final String source;

  const _ResolvedCoordinates({
    required this.latitude,
    required this.longitude,
    required this.source,
  });
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  final GetForecastUseCase getForecastUseCase;
  final IpLocationService ipLocationService;

  WeatherBloc({
    required this.getWeatherUseCase,
    required this.getForecastUseCase,
    required this.ipLocationService,
  }) : super(WeatherInitial()) {
    on<FetchWeatherByCity>(_onFetchWeatherByCity);
    on<FetchWeatherByLocation>(_onFetchWeatherByLocation);
    on<FetchCurrentLocationWeather>(_onFetchCurrentLocationWeather);
  }

  Future<void> _onFetchWeatherByCity(
    FetchWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    final result = await getWeatherUseCase.execute(city: event.cityName);

    await result.fold(
      (error) async => emit(WeatherError(error)),
      (weather) async {
        emit(
          WeatherLoaded(
            weather: weather,
            cityName: weather.cityName,
            updatedAt: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> _onFetchWeatherByLocation(
    FetchWeatherByLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    final result = await getWeatherUseCase.execute(
      lat: event.lat,
      lon: event.lon,
    );
    final forecastResult = await getForecastUseCase.execute(event.lat, event.lon);

    await result.fold(
      (error) async => emit(WeatherError(error)),
      (weather) async {
        List<double> forecast = [];
        forecastResult.fold(
          (error) => forecast = [],
          (data) => forecast = data.map((e) => e.temp).toList(),
        );

        emit(
          WeatherLoaded(
            weather: weather,
            forecast: forecast,
            cityName: weather.cityName,
            latitude: event.lat,
            longitude: event.lon,
            locationSource: 'Coordinates',
            updatedAt: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (!event.silent || state is! WeatherLoaded) {
      emit(WeatherLoading());
    }

    try {
      final coordinates = await _resolveCurrentCoordinates();
      await _loadWeatherForCoordinates(
        coordinates.latitude,
        coordinates.longitude,
        emit,
        isLiveLocation: true,
        locationSource: coordinates.source,
      );
    } catch (e) {
      emit(WeatherError(_mapLocationError(e)));
    }
  }

  Future<void> _loadWeatherForCoordinates(
    double latitude,
    double longitude,
    Emitter<WeatherState> emit, {
    bool isLiveLocation = false,
    String locationSource = 'Coordinates',
  }) async {
    final result = await getWeatherUseCase.execute(
      lat: latitude,
      lon: longitude,
    );
    final forecastResult = await getForecastUseCase.execute(latitude, longitude);

    await result.fold(
      (error) async => emit(WeatherError(error)),
      (weather) async {
        List<double> forecast = [];
        forecastResult.fold(
          (error) => forecast = [],
          (data) => forecast = data.map((e) => e.temp).toList(),
        );

        emit(
          WeatherLoaded(
            weather: weather,
            forecast: forecast,
            cityName: weather.cityName,
            latitude: latitude,
            longitude: longitude,
            isLiveLocation: isLiveLocation,
            locationSource: locationSource,
            updatedAt: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<_ResolvedCoordinates> _resolveCurrentCoordinates() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission is required to detect your weather automatically.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it from app settings.',
      );
    }

    final fallbackCoordinates = await _getFallbackCoordinates();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (fallbackCoordinates != null) {
        return _ResolvedCoordinates(
          latitude: fallbackCoordinates.latitude,
          longitude: fallbackCoordinates.longitude,
          source: 'Last known / IP',
        );
      }
      throw Exception('Please enable location services and try again.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 20),
      );
      return _ResolvedCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        source: 'GPS',
      );
    } on TimeoutException {
      if (fallbackCoordinates != null) {
        return _ResolvedCoordinates(
          latitude: fallbackCoordinates.latitude,
          longitude: fallbackCoordinates.longitude,
          source: 'Last known / IP',
        );
      }

      throw Exception(
        'Location request timed out. Turn on GPS, set an emulator location, or check your network, then try again.',
      );
    } catch (_) {
      if (fallbackCoordinates != null) {
        return _ResolvedCoordinates(
          latitude: fallbackCoordinates.latitude,
          longitude: fallbackCoordinates.longitude,
          source: 'Last known / IP',
        );
      }
      rethrow;
    }
  }

  Future<GeoCoordinates?> _getFallbackCoordinates() async {
    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return GeoCoordinates(
          latitude: lastKnownPosition.latitude,
          longitude: lastKnownPosition.longitude,
        );
      }
    } catch (_) {}

    return ipLocationService.getApproximateLocation();
  }

  String _mapLocationError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');

    if (message.contains('permission')) {
      return message;
    }

    if (message.contains('timed out') || message.contains('TimeoutException')) {
      return 'Location request timed out. Turn on GPS, set an emulator location, or check your network, then try again.';
    }

    if (message.contains('location services')) {
      return 'Please enable location services or connect the emulator to the internet, then try again.';
    }

    return 'Unable to detect your current location right now. You can try again or search by city.';
  }
}
