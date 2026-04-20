import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherAnimation extends StatelessWidget {
  final String weatherCondition;
  final double height;

  const WeatherAnimation({
    super.key,
    required this.weatherCondition,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _getLottieAsset(weatherCondition),
      height: height,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.wb_sunny, size: height, color: Colors.orange);
      },
    );
  }

  String _getLottieAsset(String condition) {
    final c = condition.toLowerCase();
    
    // 🌧️ Rain conditions
    if (c.contains('rain') || c.contains('drizzle') || c.contains('shower')) {
      return 'assets/animations/rain.json';
    }
    // ⛈️ Thunderstorm
    if (c.contains('thunderstorm')) {
      return 'assets/animations/thunderstorm.json';
    }
    // ❄️ Snow
    if (c.contains('snow')) {
      return 'assets/animations/snow.json';
    }
    // ☁️ Clouds
    if (c.contains('cloud')) {
      if (c.contains('few') || c.contains('scattered')) {
        return 'assets/animations/few_clouds.json';
      }
      return 'assets/animations/cloud.json';
    }
    // 🌫️ Mist/Fog
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
      return 'assets/animations/fog.json';
    }
    // 🌪️ Storm/Wind
    if (c.contains('tornado') || c.contains('hurricane') || c.contains('wind')) {
      return 'assets/animations/storm.json';
    }
    // ☀️ Clear / Sunny
    return 'assets/animations/sun.json';
  }
}