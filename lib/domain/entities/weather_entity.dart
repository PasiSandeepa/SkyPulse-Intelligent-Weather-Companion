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
  });
  
  @override
  List<Object?> get props => [
    cityName, temp, feelsLike, tempMin, tempMax, 
    humidity, windSpeed, condition, description, 
    iconCode, aqi, uvIndex
  ];
}