import 'package:equatable/equatable.dart';

import '../../domain/entities/weather_entity.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherEntity weather;
  final List<double> forecast;
  final String cityName;
  final double? latitude;
  final double? longitude;
  final bool isLiveLocation;
  final String locationSource;
  final DateTime updatedAt;

  const WeatherLoaded({
    required this.weather,
    this.forecast = const [],
    required this.cityName,
    this.latitude,
    this.longitude,
    this.isLiveLocation = false,
    this.locationSource = 'Manual',
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        weather,
        forecast,
        cityName,
        latitude,
        longitude,
        isLiveLocation,
        locationSource,
        updatedAt,
      ];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
