import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherAnimation extends StatelessWidget {
  final String weatherCondition;
  final String? weatherDescription;
  final String? iconCode;
  final double height;

  const WeatherAnimation({
    super.key,
    required this.weatherCondition,
    this.weatherDescription,  // ✅ fix - missing default
    this.iconCode,            // ✅ fix - missing default
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isNight = iconCode?.toLowerCase().endsWith('n') ?? false;

    final asset = _getLottieAsset(
      weatherCondition,
      description: weatherDescription,
      iconCode: iconCode,
      isNight: isNight,
    );

    // ✅ fix - asset null නම් icon show කරනවා
    if (asset == null) {
      return Icon(
        isNight ? Icons.nightlight_round : Icons.wb_sunny,
        size: height,
        color: isNight ? Colors.white : Colors.orange,
      );
    }

    return Lottie.asset(
      asset,
      height: height,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.wb_sunny, size: height, color: Colors.orange);
      },
    );
  }

  // ✅ fix - String? return type (null allow)
  String? _getLottieAsset(
    String condition, {
    String? description,
    String? iconCode,
    required bool isNight,
  }) {
    final weatherText = '$condition ${description ?? ''}'.toLowerCase();
    final code = iconCode?.toLowerCase() ?? '';

    if (code.startsWith('11') || weatherText.contains('thunderstorm')) {
      return 'assets/animations/thunderstorm.json';
    }

    if (code.startsWith('09') ||
        code.startsWith('10') ||
        weatherText.contains('rain') ||
        weatherText.contains('drizzle') ||
        weatherText.contains('shower')) {
      return 'assets/animations/rain.json';
    }

    if (code.startsWith('13') || weatherText.contains('snow')) {
      return 'assets/animations/snow.json';
    }

    if (code.startsWith('50') ||
        weatherText.contains('mist') ||
        weatherText.contains('fog') ||
        weatherText.contains('haze') ||
        weatherText.contains('smoke') ||
        weatherText.contains('dust') ||
        weatherText.contains('sand') ||
        weatherText.contains('ash')) {
      return 'assets/animations/fog.json';
    }

    if (code.startsWith('01') ||
        weatherText.contains('clear') ||
        weatherText.contains('sunny')) {
      if (isNight) return null;
      return weatherText.contains('mostly')
          ? 'assets/animations/few_clouds.json'
          : 'assets/animations/sun.json';
    }

    if (code.startsWith('02') ||
        weatherText.contains('few cloud') ||
        weatherText.contains('scattered cloud') ||
        weatherText.contains('partly cloud')) {
      return 'assets/animations/few_clouds.json';
    }

    if (code.startsWith('03') ||
        code.startsWith('04') ||
        weatherText.contains('cloud') ||
        weatherText.contains('overcast')) {
      return 'assets/animations/cloud.json';
    }

    if (weatherText.contains('tornado') ||
        weatherText.contains('hurricane') ||
        weatherText.contains('squall') ||
        weatherText.contains('wind')) {
      return 'assets/animations/storm.json';
    }

    return isNight ? null : 'assets/animations/sun.json';
  }
}