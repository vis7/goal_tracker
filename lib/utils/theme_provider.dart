import 'package:flutter/material.dart';

class ThemeProvider {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.red,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.red,
    brightness: Brightness.dark,
  );
}
