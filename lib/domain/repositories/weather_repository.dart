import 'package:dartz/dartz.dart';
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<Either<String, WeatherEntity>> getWeatherByCity(String cityName);
  Future<Either<String, WeatherEntity>> getWeatherByLocation(double lat, double lon);
  Future<Either<String, List<WeatherEntity>>> getForecast(double lat, double lon);
  Future<Either<String, int>> getAirQuality(double lat, double lon); // 🆕
}