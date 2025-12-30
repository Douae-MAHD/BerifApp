import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: appColorScheme,
      textTheme: appTextTheme,
      scaffoldBackgroundColor: appColorScheme.surface,
    );
  }
}