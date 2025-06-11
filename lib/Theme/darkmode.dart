import 'package:flutter/material.dart';

ThemeData darkMode =ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color.fromARGB(255, 14, 14, 14),
    primary: Color.fromARGB(255, 35, 35, 35),
    secondary: Color.fromARGB(255, 55, 55, 55),
    inversePrimary: Color.fromARGB(255, 228, 228, 228),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Color.fromARGB(255, 221, 220, 220),
    displayColor: Colors.white,
  ),

);