import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seedColor = Color(0xFFB85C38);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    scaffoldBackgroundColor: const Color(0xFFF7F1EA),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xFFF7F1EA),
      foregroundColor: Color(0xFF1E1E1E),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
