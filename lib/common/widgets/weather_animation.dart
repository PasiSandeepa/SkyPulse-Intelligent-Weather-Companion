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
        // Lottie file eka natnam default icon ekak pennanawa
        return Icon(Icons.wb_sunny, size: height, color: Colors.orange);
      },
    );
  }

  String _getLottieAsset(String condition) {
    final c = condition.toLowerCase();
    
    // ☀️ Clear / Sunny handling
    if (c.contains('clear') || c.contains('sunny')) {
      // MSN weather wage "Mostly sunny" welawata ira ekka podi walakulak pennanna
      if (c.contains('mostly')) {
        return 'assets/animations/few_clouds.json'; 
      }
      return 'assets/animations/sun.json';
    }
    
    // 🌧️ Rain / Drizzle / Showers
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
    
    // ☁️ Clouds handling
    if (c.contains('cloud')) {
      // "Overcast" kiyanne thada walakulu unath, paayana welawata 
      // hiru eliya thiyena nisa sun animation eka return kala.
      if (c.contains('overcast')) {
        return 'assets/animations/sun.json'; 
      }
      
      // "Few clouds" hari "Scattered clouds" welawata ira ekka walakula
      if (c.contains('few') || c.contains('scattered')) {
        return 'assets/animations/few_clouds.json'; 
      }
      
      // "Broken clouds" wage thada walakulu thiyena welawata witharak cloud eka pennanna
      return 'assets/animations/cloud.json';
    }
    
    // 🌫️ Mist/Fog/Haze
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
      return 'assets/animations/fog.json';
    }
    
    // 🌪️ Storm/Wind
    if (c.contains('tornado') || c.contains('hurricane') || c.contains('wind')) {
      return 'assets/animations/storm.json';
    }
    
    // Default fallback
    return 'assets/animations/sun.json';
  }
}