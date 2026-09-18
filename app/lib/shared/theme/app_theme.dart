import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seed = Color(0xFF1F5C4C); // vert sourd, sobre

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      scaffoldBackgroundColor: const Color(0xFFF7F4EC),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF10120F),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}
