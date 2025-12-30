import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme appTextTheme = GoogleFonts.poppinsTextTheme().copyWith(
  displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
  headlineMedium: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
  titleMedium: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF1A1C1E)),
  bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF70777C)),
);