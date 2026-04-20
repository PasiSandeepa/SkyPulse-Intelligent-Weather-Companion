import 'package:dartz/dartz.dart';
import '../../core/api/weather_api.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApi weatherApi;
  
  WeatherRepositoryImpl(this.weatherApi);
  
  @override
  Future<Either<String, WeatherEntity>> getWeatherByCity(String cityName) async {
    try {
      final jsonData = await weatherApi.getWeatherByCity(cityName);
      final model = WeatherModel.fromJson(jsonData);
      return Right(model.toEntity());
    } catch (e) {
      return Left('Failed to get weather data: $e');
    }
  }
  
  @override
  Future<Either<String, WeatherEntity>> getWeatherByLocation(double lat, double lon) async {
    try {
      final jsonData = await weatherApi.getWeatherByLocation(lat, lon);
      final model = WeatherModel.fromJson(jsonData);
      return Right(model.toEntity());
    } catch (e) {
      return Left('Failed to get location weather: $e');
    }
  }
  
  @override
  Future<Either<String, List<double>>> getForecast(double lat, double lon) async {
    try {
      final jsonData = await weatherApi.getForecast(lat, lon);
      final List<double> temps = [];
      final List<dynamic> list = jsonData['list'];
      
      for (var i = 0; i < list.length && i < 8; i++) {
        temps.add((list[i]['main']['temp'] as num).toDouble());
      }
      
      return Right(temps);
    } catch (e) {
      return Left('Failed to get forecast data: $e');
    }
  }
}