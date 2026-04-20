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
  
  const WeatherLoaded({required this.weather, this.forecast = const []});
  
  @override
  List<Object?> get props => [weather, forecast];
}

class WeatherError extends WeatherState {
  final String message;
  
  const WeatherError(this.message);
  
  @override
  List<Object?> get props => [message];
}