import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

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
        print('✅ AI: $text');
        return text ?? 'Sorry, cannot answer';
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return _fallback(question, temp, condition);
      }
    } catch (e) {
      print('❌ Error: $e');
      return _fallback(question, temp, condition);
    }
  }

  // Fallback answers
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
    if (q.contains('humid') || q.contains('sticky')) {
      return '💧 Feels humid today, stay cool!';
    }
    return '🌤️ ${temp.toStringAsFixed(0)}°C, $condition. Ask me anything about weather!';
  }

  Future<String> getWeatherInsight({
    required String cityName,
    required double temp,
    required int humidity,
    required String condition,
    required int aqi,
    required double uvIndex,
  }) async {
    if (temp > 30) return '☀️ Hot! Drink water.';
    if (temp < 20) return '❄️ Cool! Wear jacket.';
    if (condition.contains('rain')) return '☔ Take umbrella.';
    return '🌤️ Have a nice day!';
  }

  Future<String> getClothingAdvice({
    required double temp,
    required int humidity,
    required String condition,
  }) async {
    if (temp > 30) return '☀️ Light cotton clothes';
    if (temp < 22) return '❄️ Wear a jacket';
    if (condition.contains('rain')) return '☔ Take umbrella';
    return '👕 Comfortable clothes';
  }
}