import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'weather_state.dart';
import 'weather_event.dart';
import '../../domain/usecases/get_weather_usecase.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  final GetForecastUseCase getForecastUseCase;
  
  WeatherBloc({
    required this.getWeatherUseCase,
    required this.getForecastUseCase,
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
        // ✅ cityName එක event එකෙන් ගන්න
        emit(WeatherLoaded(
          weather: weather, 
          cityName: event.cityName,
        ));
      },
    );
  }
  
  Future<void> _onFetchWeatherByLocation(
    FetchWeatherByLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    
    final result = await getWeatherUseCase.execute(lat: event.lat, lon: event.lon);
    final forecastResult = await getForecastUseCase.execute(event.lat, event.lon);
    
    await result.fold(
      (error) async => emit(WeatherError(error)),
      (weather) async {
        List<double> forecast = [];
        forecastResult.fold(
          (error) => forecast = [],
          (data) => forecast = data.map((e) => e.temp).toList(),
        );
        // ✅ Get city name from coordinates
        String cityName = await _getCityName(event.lat, event.lon);
        emit(WeatherLoaded(
          weather: weather, 
          forecast: forecast,
          cityName: cityName,  // ✅ cityName එක add කරන්න
        ));
      },
    );
  }
  
  // ✅ Auto-detect current location
  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const WeatherError('Location permission required'));
          return;
        }
      }
      
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(const WeatherError('Please enable location services'));
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      print('📍 Coordinates: ${position.latitude}, ${position.longitude}');
      
      // ✅ Get city name from coordinates (AUTO-DETECT)
      String cityName = await _getCityName(position.latitude, position.longitude);
      print('📍 Auto-detected city: $cityName');
      
      final result = await getWeatherUseCase.execute(
        lat: position.latitude,
        lon: position.longitude,
      );
      final forecastResult = await getForecastUseCase.execute(
        position.latitude,
        position.longitude,
      );
      
      await result.fold(
        (error) async => emit(WeatherError(error)),
        (weather) async {
          List<double> forecast = [];
          forecastResult.fold(
            (error) => forecast = [],
            (data) => forecast = data.map((e) => e.temp).toList(),
          );
          // ✅ Send auto-detected city name with weather
          emit(WeatherLoaded(
            weather: weather,
            forecast: forecast,
            cityName: cityName,  // ✅ Auto-detected city name!
          ));
        },
      );
    } catch (e) {
      print('❌ Auto-detect error: $e');
      emit(WeatherError('Failed to get location: $e'));
    }
  }
  
  // ✅ Get city name from coordinates
  Future<String> _getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        String city = place.locality ?? 
                     place.subAdministrativeArea ?? 
                     place.administrativeArea ?? 
                     'Unknown';
        
        print('📍 City detected: $city');
        return city;
      }
      return 'Unknown';
    } catch (e) {
      print('❌ Error getting city: $e');
      return 'Unknown';
    }
  }
}