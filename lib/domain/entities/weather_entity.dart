import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
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

  const WeatherEntity({
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
  
  // ✅ CopyWith method - AQI එක update කරන්න
  WeatherEntity copyWith({
    String? cityName,
    double? temp,
    double? feelsLike,
    double? tempMin,
    double? tempMax,
    int? humidity,
    double? windSpeed,
    String? condition,
    String? description,
    String? iconCode,
    int? aqi,
    double? uvIndex,
    double? visibility,
    int? sunrise,
    int? sunset,
  }) {
    return WeatherEntity(
      cityName: cityName ?? this.cityName,
      temp: temp ?? this.temp,
      feelsLike: feelsLike ?? this.feelsLike,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      aqi: aqi ?? this.aqi,
      uvIndex: uvIndex ?? this.uvIndex,
      visibility: visibility ?? this.visibility,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
    );
  }

  @override
  List<Object?> get props => [
    cityName, temp, feelsLike, tempMin, tempMax,
    humidity, windSpeed, condition, description,
    iconCode, aqi, uvIndex, visibility, sunrise, sunset,
  ];
}