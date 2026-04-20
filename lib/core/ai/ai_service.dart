import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_constants.dart';

class AIService {
  late final GenerativeModel _model;
  
  AIService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConstants.geminiApiKey,
    );
  }
  
  // Weather insight with practical advice
  Future<String> getWeatherInsight({
    required String cityName,
    required double temp,
    required int humidity,
    required String condition,
    required int aqi,
    required double uvIndex,
  }) async {
    final prompt = '''
You are SkyPulse AI - Sri Lankan weather assistant.
Current weather in $cityName:
- Temperature: ${temp.toStringAsFixed(1)}°C
- Humidity: $humidity%
- Condition: $condition
- Air Quality: ${aqi > 100 ? 'Poor' : 'Good'} (AQI: $aqi)
- UV Index: ${uvIndex.toStringAsFixed(1)}

Give practical advice in English with emojis.
Keep it short (2-3 sentences). Include tips about umbrella, mask, sunscreen if needed.
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze weather data';
    } catch (e) {
      return 'AI Service Error: $e';
    }
  }
  
  // Voice assistant - answer user questions
  Future<String> answerQuestion(String question, Map<String, dynamic> weatherData) async {
    final prompt = '''
You are SkyPulse AI weather assistant for Sri Lanka.
Current weather: $weatherData
User asks: "$question"

Answer helpfully in English with emojis.
Keep answer to 2-3 sentences.
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sorry, I could not answer that';
    } catch (e) {
      return 'Sorry, AI service error: $e';
    }
  }
  
  // Clothing recommendation
  Future<String> getClothingAdvice({
    required double temp,
    required int humidity,
    required String condition,
  }) async {
    final prompt = '''
Weather: ${temp.toStringAsFixed(1)}°C, $humidity% humidity, $condition.
Recommend what to wear in English with emojis.
Keep it very short (1 sentence).
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '👕 Wear comfortable clothes';
    } catch (e) {
      return '👕 Wear regular clothes';
    }
  }
}