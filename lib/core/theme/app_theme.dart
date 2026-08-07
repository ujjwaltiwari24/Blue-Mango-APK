import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor:
    const Color(0xff001233),

    colorScheme:
    const ColorScheme.dark(
      primary: Color(0xff0466C8),
      secondary: Color(0xff192BC2),
    ),
  );
}