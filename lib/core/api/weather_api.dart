import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../constants/app_constants.dart';

class WeatherApi {
  late final Dio _dio;
  
  WeatherApi() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.weatherBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
   
    _dio.interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(minutes: AppConstants.cacheMaxAgeMinutes),
      ),
    ));
  }
  

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': cityName,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Weather API error: ${e.response?.statusCode} - ${e.message}');
    }
  }
  
  
  Future<Map<String, dynamic>> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Location weather error: ${e.message}');
    }
  }
  
  
  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Forecast API error: ${e.message}');
    }
  }
  

  Future<Map<String, dynamic>> getAirQuality(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/air_pollution',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.weatherApiKey,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('AQI API error: ${e.message}');
    }
  }
}