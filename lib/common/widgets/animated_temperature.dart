import 'package:flutter/material.dart';

class AnimatedTemperature extends StatefulWidget {
  final double temperature;
  final double fontSize;
  final Color color;

  const AnimatedTemperature({
    super.key,
    required this.temperature,
    this.fontSize = 56,
    this.color = Colors.white,
  });

  @override
  State<AnimatedTemperature> createState() => _AnimatedTemperatureState();
}

class _AnimatedTemperatureState extends State<AnimatedTemperature> {
  double _displayTemp = 0;

  @override
  void initState() {
    super.initState();
    _displayTemp = widget.temperature;
    // Animate after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _displayTemp = widget.temperature;
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedTemperature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temperature != widget.temperature) {
      // Animate to new temperature
      setState(() {
        _displayTemp = widget.temperature;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: _displayTemp, end: widget.temperature),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${value.toStringAsFixed(1)}°C',
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
        );
      },
    );
  }
}