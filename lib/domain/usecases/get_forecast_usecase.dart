import 'package:dartz/dartz.dart';

import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecastUseCase {
  final WeatherRepository repository;

  GetForecastUseCase(this.repository);

  Future<Either<String, List<WeatherEntity>>> execute(double lat, double lon) {
    return repository.getForecast(lat, lon);
  }
}
