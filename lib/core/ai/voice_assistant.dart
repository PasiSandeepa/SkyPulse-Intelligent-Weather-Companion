import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'ai_service.dart';
import '../../domain/entities/weather_entity.dart';

class VoiceAssistant {
  // Create instances of required services
  final SpeechToText _speech = SpeechToText();  // Converts voice to text
  final FlutterTts _flutterTts = FlutterTts();  // Converts text to voice
  final AIService _aiService = AIService();      // AI to answer questions
  
  bool _isListening = false;
  String _recognizedText = '';
  
  // Constructor - automatically initializes when created
  VoiceAssistant() {
    _init();
  }
  
  // Initialize both services
  Future<void> _init() async {
    // Initialize speech recognition
    await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    
    // Initialize Text-to-Speech (Sinhala support)
    await _flutterTts.setLanguage('si');  // 'si' = Sinhala, 'en' = English
    await _flutterTts.setSpeechRate(0.5);  // Speed (0.0 to 1.0)
    await _flutterTts.setPitch(1.0);       // Voice pitch
  }
  
  // Start listening for voice commands
  Future<String> startListening() async {
    _recognizedText = '';
    _isListening = true;
    
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          print('🎤 Recognized: $_recognizedText');
        },
        listenFor: const Duration(seconds: 5),   // Listen for 5 seconds
        pauseFor: const Duration(seconds: 2),    // Pause for 2 seconds
        localeId: 'si_LK', // Sinhala language (change to 'en_US' for English)
      );
    }
    
    // Wait for speech to complete
    await Future.delayed(const Duration(seconds: 5));
    _isListening = false;
    _speech.stop();
    
    return _recognizedText;
  }
  
  // Stop listening manually
  void stopListening() {
    _isListening = false;
    _speech.stop();
  }
  
  // Process voice command using your AIService
  Future<String> processCommand(String command, WeatherEntity? weather) async {
    if (command.isEmpty) {
      return '⚠️ Please speak again.';  // English message
    }
    
    // Prepare weather data for AI
    final weatherData = {
      'city': weather?.cityName ?? 'your location',
      'temperature': weather?.temp.toStringAsFixed(1) ?? 'N/A',
      'condition': weather?.condition ?? 'N/A',
      'humidity': weather?.humidity ?? 'N/A',
      'wind_speed': weather?.windSpeed.toStringAsFixed(1) ?? 'N/A',
      'aqi': weather?.aqi ?? 50,
      'uv_index': weather?.uvIndex ?? 5.0,
    };
    
    // Use your existing AIService to answer
    final answer = await _aiService.answerQuestion(command, weatherData);
    return answer;
  }
  
  // Speak text using TTS
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
  
  // Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
  
  // Check if currently listening
  bool get isListening => _isListening;
  
  // Dispose resources (call when done)
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
  }
}