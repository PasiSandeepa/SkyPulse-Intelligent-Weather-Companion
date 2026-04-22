import 'package:dartz/dartz.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;
  
  GetWeatherUseCase(this.repository);
  
  Future<Either<String, WeatherEntity>> execute({
    String? city,
    double? lat,
    double? lon,
  }) async {
    if (city != null && city.isNotEmpty) {
      return repository.getWeatherByCity(city);
    } else if (lat != null && lon != null) {
      return repository.getWeatherByLocation(lat, lon);
    } else {
      return const Left('City or location data එකක් දෙන්න');
    }
  }
}

class GetForecastUseCase {
  final WeatherRepository repository;
  
  GetForecastUseCase(this.repository);
  

  Future<Either<String, List<WeatherEntity>>> execute(double lat, double lon) {
    return repository.getForecast(lat, lon);
  }
}