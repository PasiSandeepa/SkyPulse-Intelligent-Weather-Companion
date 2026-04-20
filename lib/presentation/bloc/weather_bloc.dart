import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
        emit(WeatherLoaded(weather: weather));
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
          (data) => forecast = data,
        );
        emit(WeatherLoaded(weather: weather, forecast: forecast));
      },
    );
  }
  
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
      Position position = await Geolocator.getCurrentPosition();
      
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
            (data) => forecast = data,
          );
          emit(WeatherLoaded(weather: weather, forecast: forecast));
        },
      );
    } catch (e) {
      emit(WeatherError('Failed to get location: $e'));
    }
  }
}