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
  final String cityName;  // ✅ මෙය add කරන්න
  
  const WeatherLoaded({
    required this.weather, 
    this.forecast = const [],
    required this.cityName,  // ✅ required
  });
  
  @override
  List<Object?> get props => [weather, forecast, cityName];
}

class WeatherError extends WeatherState {
  final String message;
  
  const WeatherError(this.message);
  
  @override
  List<Object?> get props => [message];
}