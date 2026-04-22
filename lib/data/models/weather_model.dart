import '../../domain/entities/weather_entity.dart';

class WeatherModel {
  final String cityName;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String iconCode;
  final int aqi;
  final double uvIndex;
  final double visibility;
  final int sunrise;
  final int sunset;

  WeatherModel({
    required this.cityName,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.aqi,
    required this.uvIndex,
    this.visibility = 10.0,
    this.sunrise = 0,
    this.sunset = 0,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temp: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      visibility: ((json['visibility'] ?? 10000) / 1000).toDouble(),
      sunrise: json['sys']['sunrise'] as int,
      sunset: json['sys']['sunset'] as int,
      aqi: 50,
      uvIndex: 5.0,
    );
  }

  WeatherEntity toEntity() {
    return WeatherEntity(
      cityName: cityName,
      temp: temp,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed,
      condition: condition,
      description: description,
      iconCode: iconCode,
      aqi: aqi,
      uvIndex: uvIndex,
      visibility: visibility,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  WeatherModel updateWith({int? aqi, double? uvIndex}) {
    return WeatherModel(
      cityName: cityName,
      temp: temp,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed,
      condition: condition,
      description: description,
      iconCode: iconCode,
      visibility: visibility,
      sunrise: sunrise,
      sunset: sunset,
      aqi: aqi ?? this.aqi,
      uvIndex: uvIndex ?? this.uvIndex,
    );
  }
}