import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/ai/ai_service.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceAssistantDialog extends StatefulWidget {
  final WeatherEntity? currentWeather;
  const VoiceAssistantDialog({super.key, this.currentWeather});

  @override
  State<VoiceAssistantDialog> createState() => _VoiceAssistantDialogState();
}

class _VoiceAssistantDialogState extends State<VoiceAssistantDialog> {
  late SpeechToText _speech;
  late FlutterTts _flutterTts;
  late AIService _aiService;
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String _response = '';
  String _status = 'Tap "Speak Now"';
  bool _isAvailable = false;
  
  @override
  void initState() {
    super.initState();
    _initServices();
  }
  
  Future<void> _initServices() async {
    _speech = SpeechToText();
    _flutterTts = FlutterTts();
    _aiService = AIService();
    
    await _flutterTts.setLanguage('en');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
      },
      onError: (error) {
        print('Speech error: $error');
        if (mounted) {
          setState(() {
            _status = '❌ Speech error: $error';
          });
        }
      },
    );
    
    if (mounted) {
      setState(() {
        _status = _isAvailable ? '✅ Ready - Tap "Speak Now"' : '❌ Speech not available';
      });
    }
  }
  
  Future<void> _startListening() async {
    // ✅ 1. Request microphone permission first
    PermissionStatus micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (mounted) {
          setState(() {
            _status = '❌ Microphone permission denied';
            _response = 'Please allow microphone in settings';
          });
        }
        return;
      }
    }
    
    // ✅ 2. Re-initialize if needed
    if (!_isAvailable) {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
        },
        onError: (error) {
          print('Speech error: $error');
          if (mounted) {
            setState(() {
              _status = '❌ Speech error: $error';
            });
          }
        },
      );
    }
    
    // ✅ 3. Check if speech is available
    if (!_isAvailable) {
      if (mounted) {
        setState(() {
          _status = '❌ Speech recognition not available';
          _response = 'Please restart the app';
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isListening = true;
        _status = '🎤 Listening... Speak now';
        _recognizedText = '';
        _response = '';
      });
    }
    
    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          }
          print('🎤 Recognized: ${result.recognizedWords}');
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        localeId: 'en_US',
      );
      
      await Future.delayed(const Duration(seconds: 5));
      
      if (mounted && _isListening) {
        _isListening = false;
        await _speech.stop();
        await _processCommand();
      }
    } catch (e) {
      print('Listen error: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _status = '❌ Error: $e';
          _response = 'Please check microphone';
        });
      }
    }
  }
  
  Future<void> _processCommand() async {
    if (_recognizedText.isEmpty) {
      if (mounted) {
        setState(() {
          _status = '⚠️ No speech detected';
          _response = 'Please tap "Speak Now" and speak clearly';
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isProcessing = true;
        _status = '🤔 Getting AI response...';
      });
    }
    
    final weatherData = {
      'city': widget.currentWeather?.cityName ?? 'your location',
      'temperature': widget.currentWeather?.temp.toStringAsFixed(1) ?? 'N/A',
      'condition': widget.currentWeather?.condition ?? 'N/A',
      'humidity': widget.currentWeather?.humidity ?? 'N/A',
      'wind_speed': widget.currentWeather?.windSpeed.toStringAsFixed(1) ?? 'N/A',
    };
    
    try {
      final answer = await _aiService.answerQuestion(_recognizedText, weatherData);
      
      if (mounted) {
        setState(() {
          _response = answer;
          _isProcessing = false;
          _status = '✅ Response ready';
        });
      }
      
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
      await _flutterTts.speak(answer);
      if (mounted) {
        setState(() => _isSpeaking = false);
        _status = '✅ Ready - Tap "Speak Now"';
      }
      
    } catch (e) {
      print('AI Error: $e');
      if (mounted) {
        setState(() {
          _response = 'Sorry, error occurred. Please try again.';
          _isProcessing = false;
          _status = '❌ Error';
        });
      }
    }
  }
  
  void _cancel() {
    if (_isListening) _speech.stop();
    if (_isSpeaking) _flutterTts.stop();
    Navigator.pop(context);
  }
  
  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B21A5), Color(0xFF2563EB)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Weather Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Animated Mic Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening 
                      ? Colors.red.withOpacity(0.3) 
                      : (_isSpeaking 
                          ? Colors.green.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    if (_isListening)
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                  ],
                ),
                child: Icon(
                  _isSpeaking 
                      ? Icons.volume_up 
                      : (_isListening ? Icons.mic : Icons.mic_none),
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Help Text
              const Text(
                'Ask me about the weather!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              
              // Recognized Text
              if (_recognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'You said:',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '“$_recognizedText”',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              
              // AI Response
              if (_response.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Assistant:',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _response,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              
              // Loading Indicator
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              
              // Buttons Row
              Row(
                children: [
                  // Speak Now Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isProcessing || _isListening) ? null : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isListening ? 'Listening...' : 'Speak Now',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the dialog
Future<void> showVoiceAssistant(
  BuildContext context,
  WeatherEntity? weather,
) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => VoiceAssistantDialog(
      currentWeather: weather,
    ),
  );
}