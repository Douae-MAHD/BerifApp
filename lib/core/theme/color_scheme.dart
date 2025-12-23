import 'package:flutter/material.dart';

class AppColorScheme {
  static ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0066CC), // Bleu moderne
    brightness: Brightness.light,
    primary: const Color(0xFF0066CC),
    secondary: const Color(0xFF66BB6A),
    tertiary: const Color(0xFFFFB74D),
  );

  static ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5D9CEC),
    brightness: Brightness.dark,
    primary: const Color(0xFF5D9CEC),
    secondary: const Color(0xFF81C784),
    tertiary: const Color(0xFFFFA726),
  );
}