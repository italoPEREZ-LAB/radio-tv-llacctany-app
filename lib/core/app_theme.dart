import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7B61FF),
      secondary: Color(0xFFFF4D9D),
    ),
  );
}