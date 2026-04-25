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
      final lat = (jsonData['coord']['lat'] as num?)?.toDouble();
      final lon = (jsonData['coord']['lon'] as num?)?.toDouble();
      final aqi = await _resolveAirQuality(lat, lon);

      return Right(model.updateWith(aqi: aqi).toEntity());
    } catch (e) {
      return Left('Failed to get weather data: $e');
    }
  }

  @override
  Future<Either<String, WeatherEntity>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    try {
      final jsonData = await weatherApi.getWeatherByLocation(lat, lon);
      final model = WeatherModel.fromJson(jsonData);
      final aqi = await _resolveAirQuality(lat, lon);

      return Right(model.updateWith(aqi: aqi).toEntity());
    } catch (e) {
      return Left('Failed to get location weather: $e');
    }
  }

  @override
  Future<Either<String, int>> getAirQuality(double lat, double lon) async {
    try {
      final jsonData = await weatherApi.getAirQuality(lat, lon);
      final list = jsonData['list'] as List<dynamic>?;

      if (list != null && list.isNotEmpty) {
        final aqi = list[0]['main']['aqi'] as int;
        const aqiMap = <int, int>{
          1: 25,
          2: 75,
          3: 125,
          4: 200,
          5: 350,
        };
        return Right(aqiMap[aqi] ?? 50);
      }

      return const Right(50);
    } catch (e) {
      return Left('AQI error: $e');
    }
  }

  @override
  Future<Either<String, List<WeatherEntity>>> getForecast(
    double lat,
    double lon,
  ) async {
    try {
      final jsonData = await weatherApi.getForecast(lat, lon);
      final cityData = jsonData['city'] as Map<String, dynamic>? ?? {};
      final cityName = cityData['name'] as String? ?? 'Unknown';
      final sunrise = (cityData['sunrise'] as num?)?.toInt() ?? 0;
      final sunset = (cityData['sunset'] as num?)?.toInt() ?? 0;
      final list = jsonData['list'] as List<dynamic>? ?? [];
      final forecasts = <WeatherEntity>[];
      final aqi = await _resolveAirQuality(lat, lon);

      for (var i = 0; i < list.length && i < 8; i++) {
        final item = list[i] as Map<String, dynamic>;
        final main = item['main'] as Map<String, dynamic>? ?? {};
        final weatherList = item['weather'] as List<dynamic>? ?? [];
        final weather = weatherList.isNotEmpty
            ? weatherList.first as Map<String, dynamic>
            : <String, dynamic>{};
        final wind = item['wind'] as Map<String, dynamic>? ?? {};

        forecasts.add(
          WeatherEntity(
            cityName: cityName,
            temp: (main['temp'] as num?)?.toDouble() ?? 0,
            feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
            tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0,
            tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0,
            humidity: (main['humidity'] as num?)?.toInt() ?? 0,
            windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
            condition: weather['main'] as String? ?? 'Unknown',
            description: weather['description'] as String? ?? 'Unknown',
            iconCode: weather['icon'] as String? ?? '01d',
            aqi: aqi,
            uvIndex: 5.0,
            visibility:
                ((item['visibility'] as num?)?.toDouble() ?? 10000) / 1000,
            sunrise: sunrise,
            sunset: sunset,
          ),
        );
      }

      return Right(forecasts);
    } catch (e) {
      return Left('Failed to get forecast data: $e');
    }
  }

  Future<int> _resolveAirQuality(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      return 50;
    }

    final aqiResult = await getAirQuality(lat, lon);
    return aqiResult.fold((_) => 50, (value) => value);
  }
}
