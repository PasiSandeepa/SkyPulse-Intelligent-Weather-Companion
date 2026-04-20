import 'package:flutter/material.dart';
import '../../core/ai/ai_service.dart';
import '../../domain/entities/weather_entity.dart';

class AIInsightCard extends StatefulWidget {
  final WeatherEntity weather;

  const AIInsightCard({super.key, required this.weather});

  @override
  State<AIInsightCard> createState() => _AIInsightCardState();
}

class _AIInsightCardState extends State<AIInsightCard> {
  late AIService _aiService;
  String _insight = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _aiService = AIService();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    final insight = await _aiService.getWeatherInsight(
      cityName: widget.weather.cityName,
      temp: widget.weather.temp,
      humidity: widget.weather.humidity,
      condition: widget.weather.condition,
      aqi: widget.weather.aqi,
      uvIndex: widget.weather.uvIndex,
    );

    setState(() {
      _insight = insight;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  'AI Insight',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(_insight),
          ],
        ),
      ),
    );
  }
}