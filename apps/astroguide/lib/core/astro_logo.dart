import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AstroLogoWidget extends StatelessWidget {
  const AstroLogoWidget({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AstroPalette.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AstroPalette.gold.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AstroPalette.ink.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
          Text(
            'AN',
            style: TextStyle(
              color: AstroPalette.ink,
              fontFamily: 'serif',
              fontSize: size * 0.42,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
