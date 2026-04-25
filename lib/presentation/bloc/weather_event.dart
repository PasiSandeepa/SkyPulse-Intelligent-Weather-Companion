import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchWeatherByCity extends WeatherEvent {
  final String cityName;
  
  const FetchWeatherByCity(this.cityName);
  
  @override
  List<Object?> get props => [cityName];
}

class FetchWeatherByLocation extends WeatherEvent {
  final double lat;
  final double lon;
  
  const FetchWeatherByLocation(this.lat, this.lon);
  
  @override
  List<Object?> get props => [lat, lon];
}

class FetchCurrentLocationWeather extends WeatherEvent {
  final bool silent;

  const FetchCurrentLocationWeather({this.silent = false});

  @override
  List<Object?> get props => [silent];
}
