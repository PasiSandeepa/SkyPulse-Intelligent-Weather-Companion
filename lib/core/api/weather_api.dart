import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherApi {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  String get _apiKey {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENWEATHER_API_KEY is missing in .env');
    }
    return apiKey;
  }

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) {
    return _getJson(
      '/weather',
      {
        'q': cityName,
        'appid': _apiKey,
        'units': 'metric',
      },
    );
  }

  Future<Map<String, dynamic>> getWeatherByLocation(double lat, double lon) {
    return _getJson(
      '/weather',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
      },
    );
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) {
    return _getJson(
      '/forecast',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
      },
    );
  }

  Future<Map<String, dynamic>> getAirQuality(double lat, double lon) {
    return _getJson(
      '/air_pollution',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
      },
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String path,
    Map<String, String> queryParameters,
  ) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(body as Map);
    }

    final message = body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Unknown API error'
        : 'Unknown API error';
    throw Exception(message);
  }
}
