import 'package:flutter/material.dart';

abstract final class AstroPalette {
  static const ink = Color(0xFF0B0716);
  static const plum = Color(0xFF19102E);
  static const parchment = Color(0xFFF7F0E3);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5E0A6);
  static const seaGlass = Color(0xFF5B9285);
  static const muted = Color(0xFF6B6E82);
  static const line = Color(0xFF382E52);
  static const danger = Color(0xFFD9534F);

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B0716),
      Color(0xFF17102B),
      Color(0xFF24183E),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFF7E2A9),
      Color(0xFFD4AF37),
      Color(0xFFC79E3A),
    ],
  );

  static BoxDecoration clay3D({Color? baseColor, List<BoxShadow>? shadows, bool isDark = true}) => BoxDecoration(
    color: baseColor ?? (isDark ? const Color(0xFF1E1436) : Colors.white),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? Colors.white.withValues(alpha: 0.28) : const Color(0xFFD4AF37).withValues(alpha: 0.4),
      width: 1.8,
    ),
    boxShadow: shadows ?? [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.grey.shade400).withValues(alpha: isDark ? 0.7 : 0.35),
        blurRadius: isDark ? 16 : 12,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: (isDark ? const Color(0xFF8C52FF) : const Color(0xFFD4AF37)).withValues(alpha: isDark ? 0.35 : 0.15),
        blurRadius: 24,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.15 : 0.8),
        blurRadius: 1,
        spreadRadius: 1,
        offset: const Offset(0, -2),
      ),
    ],
  );

  static BoxDecoration card3D({Color? baseColor, Color? borderColor, List<BoxShadow>? shadows, bool isDark = true}) => clay3D(baseColor: baseColor, shadows: shadows, isDark: isDark);

  static BoxDecoration clayButton3D({Color? color}) => BoxDecoration(
    color: color ?? const Color(0xFFD4AF37),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.4),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.35),
        blurRadius: 2,
        offset: const Offset(0, -3),
      ),
    ],
  );
}

ThemeData buildAstroTheme([Brightness brightness = Brightness.dark]) {
  final isDark = brightness == Brightness.dark;
  final surfaceColor = isDark ? AstroPalette.ink : const Color(0xFFFAF7F2);
  final cardColor = isDark ? AstroPalette.plum : Colors.white;
  final textColor = isDark ? AstroPalette.parchment : const Color(0xFF1A122E);
  final mutedColor = isDark ? AstroPalette.muted : const Color(0xFF5E6075);

  final scheme = ColorScheme.fromSeed(
    seedColor: AstroPalette.gold,
    brightness: brightness,
    surface: surfaceColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: AstroPalette.gold,
      onPrimary: isDark ? AstroPalette.ink : Colors.white,
      secondary: AstroPalette.seaGlass,
      onSurface: textColor,
      surface: cardColor,
      error: AstroPalette.danger,
    ),
    scaffoldBackgroundColor: surfaceColor,
    fontFamily: 'sans-serif',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColor, height: 1.55),
      bodyMedium: TextStyle(color: textColor, height: 1.5),
      bodySmall: TextStyle(color: mutedColor, height: 1.45),
      labelLarge: const TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF140C24) : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? AstroPalette.line : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? AstroPalette.line : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.gold, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AstroPalette.danger),
      ),
      labelStyle: TextStyle(color: mutedColor, fontSize: 14),
      hintStyle: TextStyle(color: mutedColor, fontSize: 14),
    ),
    dividerColor: isDark ? AstroPalette.line : Colors.grey.shade300,
  );
}
