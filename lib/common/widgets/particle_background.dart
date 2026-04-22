import 'package:flutter/material.dart';

class ParticleBackground extends StatelessWidget {
  final Color color;
  final Widget child;

  const ParticleBackground({
    super.key,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: child,
    );
  }
}