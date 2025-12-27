import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7),
    ),
    useMaterial3: true,
  );
}
