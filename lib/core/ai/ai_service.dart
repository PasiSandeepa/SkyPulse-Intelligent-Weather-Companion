import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';


class AIService {
  Future<String> answerQuestion(
      String question, Map<String, dynamic> weatherData) async {
    double temp = 24.0;
    if (weatherData['temperature'] is String) {
      temp = double.tryParse(weatherData['temperature']) ?? 24.0;
    } else if (weatherData['temperature'] is num) {
      temp = (weatherData['temperature'] as num).toDouble();
    }

    String condition = weatherData['condition']?.toString() ?? 'sunny';
    String city = weatherData['city']?.toString() ?? 'Colombo';

    final prompt = '''
Weather in $city: ${temp}°C, $condition.
User asks: "$question"
Answer in English. Keep short (1 sentence).
''';

    try {
      final apiKey = AppConstants.geminiApiKey;
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text ?? 'Sorry, cannot answer';
      } else {
        return _fallback(question, temp, condition);
      }
    } catch (e) {
      return _fallback(question, temp, condition);
    }
  }

  String _fallback(String question, double temp, String condition) {
    String q = question.toLowerCase();
    if (q.contains('best time') || q.contains('when')) {
      return temp < 28 ? '🌅 Morning 6-9AM is best!' : '🌆 Evening after 5PM is cooler';
    }
    if (q.contains('hik') || q.contains('outdoor') || q.contains('go')) {
      return temp > 32 ? '🥵 Too hot! Go early morning' : '✅ Good weather for outdoor activities!';
    }
    if (q.contains('temperature') || q.contains('hot') || q.contains('cold')) {
      return '🌡️ Currently ${temp.toStringAsFixed(0)}°C - ${temp > 30 ? "Very hot!" : temp < 22 ? "Cool weather" : "Pleasant!"}';
    }
    if (q.contains('jacket') || q.contains('wear') || q.contains('cloth')) {
      return temp < 22 ? '❄️ Wear a jacket' : temp > 32 ? '👕 Light clothes only' : '👔 Comfortable clothes';
    }
    if (q.contains('rain') || q.contains('umbrella')) {
      return condition.toLowerCase().contains('rain') ? '☔ Yes! Take an umbrella' : '☀️ No rain expected';
    }
    if (q.contains('sun') || q.contains('cream') || q.contains('uv')) {
      return temp > 28 ? '🧴 Yes! Use SPF 50+ sun cream' : '😊 Sun cream optional today';
    }
    if (q.contains('weather') || q.contains('today')) {
      return '🌤️ $condition, ${temp.toStringAsFixed(0)}°C - ${temp > 30 ? "Stay hydrated!" : "Nice day!"}';
    }
    return '🌤️ ${temp.toStringAsFixed(0)}°C, $condition. Ask me anything about weather!';
  }

  // ✅ FIXED — Gemini API call කරනවා, hardcoded නෑ
  Future<String> getWeatherInsight({
    required String cityName,
    required double temp,
    required int humidity,
    required String condition,
    required int aqi,
    required double uvIndex,
  }) async {
    // First try Gemini API
    try {
      final apiKey = AppConstants.geminiApiKey;
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

      final prompt = '''
You are a weather assistant. Current weather in $cityName:
- Temperature: ${temp.toStringAsFixed(1)}°C
- Condition: $condition
- Humidity: $humidity%
- AQI: $aqi (${_aqiLabel(aqi)})
- UV Index: ${uvIndex.toStringAsFixed(1)}

Give practical weather advice in 2-3 SHORT sentences.
Be SPECIFIC to the actual condition "$condition".
If raining → warn about rain and umbrella.
If hot → hydration advice.
If good AQI → mention it's safe outside.
Do NOT say generic phrases like "Have a nice day" when weather is bad.
Use relevant emojis. Reply in English only.
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text']
            ?.toString()
            .trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    } catch (e) {
      debugPrint('❌ Gemini insight error: $e');
    }

    // Fallback — condition based, NOT generic
    return _insightFallback(
      cityName: cityName,
      temp: temp,
      humidity: humidity,
      condition: condition,
      aqi: aqi,
      uvIndex: uvIndex,
    );
  }

  // ✅ Condition-specific fallback — "have a nice day" නෑ rain ලේ
  String _insightFallback({
    required String cityName,
    required double temp,
    required int humidity,
    required String condition,
    required int aqi,
    required double uvIndex,
  }) {
    final c = condition.toLowerCase();

    if (c.contains('thunderstorm')) {
      return '⛈️ Thunderstorm warning for $cityName! Stay indoors and avoid open areas. Unplug electronics as a precaution.';
    }
    if (c.contains('heavy rain')) {
      return '🌧️ Heavy rain in $cityName — take an umbrella and drive carefully. Avoid flooded roads.';
    }
    if (c.contains('rain') || c.contains('drizzle') || c.contains('shower')) {
      return '☔ Rainy weather in $cityName (${temp.toStringAsFixed(0)}°C). Carry an umbrella and wear waterproof footwear. Good time to stay indoors!';
    }
    if (c.contains('snow')) {
      return '❄️ Snowy conditions in $cityName! Dress in warm layers and watch out for icy surfaces.';
    }
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) {
      return '🌫️ Low visibility in $cityName due to $condition. Drive slowly and use fog lights.';
    }
    if (c.contains('cloud')) {
      if (temp > 30) {
        return '⛅ Cloudy but still hot at ${temp.toStringAsFixed(0)}°C in $cityName. Stay hydrated and avoid prolonged sun exposure.';
      }
      return '☁️ Overcast skies in $cityName at ${temp.toStringAsFixed(0)}°C. Comfortable weather — good for outdoor activities!';
    }
    if (temp > 35) {
      return '🥵 Extreme heat in $cityName at ${temp.toStringAsFixed(0)}°C! Drink plenty of water, stay in shade, and avoid outdoor activity between 11AM–3PM.';
    }
    if (temp > 30) {
      return '☀️ Hot day in $cityName at ${temp.toStringAsFixed(0)}°C. Stay hydrated and apply sunscreen (UV: ${uvIndex.toStringAsFixed(1)}). Best to go out early morning or evening.';
    }
    if (temp < 20) {
      return '🧥 Cool weather in $cityName at ${temp.toStringAsFixed(0)}°C. Wear a jacket if heading out. ${aqi < 50 ? "Air quality is great today!" : ""}';
    }

    // Only say "nice day" when weather is actually nice
    return '🌤️ Pleasant weather in $cityName — ${temp.toStringAsFixed(0)}°C with $condition. ${humidity > 80 ? "Feels a bit humid though." : "Great time to head outside!"}';
  }

  String _aqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Fair';
    if (aqi <= 150) return 'Moderate';
    if (aqi <= 200) return 'Poor';
    return 'Very Poor';
  }

  Future<String> getClothingAdvice({
    required double temp,
    required int humidity,
    required String condition,
  }) async {
    if (temp > 30) return '☀️ Light cotton clothes';
    if (temp < 22) return '❄️ Wear a jacket';
    if (condition.toLowerCase().contains('rain')) return '☔ Raincoat or umbrella';
    return '👕 Comfortable clothes';
  }
}