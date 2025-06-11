import 'package:flutter/material.dart';

ThemeData lightMode =ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color.fromARGB(255, 114, 125, 115), // Color.fromARGB(255, 240, 209, 251),
    primary: Color.fromARGB(255, 170, 185, 154),
    secondary: Color.fromARGB(255, 208, 221, 208),
    inversePrimary: Colors.grey.shade800,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey.shade800,
    displayColor: Colors.black,
  ),

);