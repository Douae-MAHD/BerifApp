import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF5F7F9);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textLight = Color(0xFF70777C);
}

const ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primaryRed,
  onPrimary: Colors.white,
  secondary: Color(0xFF2196F3),
  onSecondary: Colors.white,
  error: Color(0xFFBA1A1A),
  onError: Colors.white,
  surface: AppColors.surface,
  onSurface: AppColors.textDark,
  outline: Color(0xFFC4C7C5),
);