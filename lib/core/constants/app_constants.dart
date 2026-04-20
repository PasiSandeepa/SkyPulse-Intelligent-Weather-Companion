import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Keys from .env file
  static String get weatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // API URLs
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoBaseUrl = 'https://api.openweathermap.org/geo/1.0';
  
  // Cache Settings
  static const int cacheMaxAgeMinutes = 10;
  
  // App Settings
  static const String appName = 'SkyPulse';
  static const String defaultCity = 'Colombo';
}