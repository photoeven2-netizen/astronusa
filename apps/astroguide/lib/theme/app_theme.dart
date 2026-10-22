import 'package:flutter/material.dart';

abstract final class AstroPalette {
  static const ink = Color(0xFF0B1020);
  static const plum = Color(0xFF171326);
  static const parchment = Color(0xFFF3EAD8);
  static const gold = Color(0xFFD8B56D);
  static const seaGlass = Color(0xFF8CB9B2);
  static const muted = Color(0xFFB2B4C3);
  static const line = Color(0xFF34354A);
  static const danger = Color(0xFFFFB4A7);
}

ThemeData buildAstroTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AstroPalette.gold,
    brightness: Brightness.dark,
    surface: AstroPalette.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: AstroPalette.gold,
      onPrimary: AstroPalette.ink,
      secondary: AstroPalette.seaGlass,
      onSurface: AstroPalette.parchment,
      surface: AstroPalette.ink,
      error: AstroPalette.danger,
    ),
    scaffoldBackgroundColor: AstroPalette.ink,
    fontFamily: 'sans-serif',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AstroPalette.parchment, height: 1.55),
      bodyMedium: TextStyle(color: AstroPalette.parchment, height: 1.5),
      bodySmall: TextStyle(color: AstroPalette.muted, height: 1.45),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AstroPalette.plum,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.danger),
      ),
      labelStyle: const TextStyle(color: AstroPalette.muted),
      hintStyle: const TextStyle(color: AstroPalette.muted),
    ),
    dividerColor: AstroPalette.line,
  );
}
