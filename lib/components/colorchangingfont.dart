import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

Widget colorChangingText({
  required String text,
  double fontSize = 60,
  FontWeight fontWeight = FontWeight.bold,
  List<Color>? colors,
  Duration duration = const Duration(milliseconds: 2500),
}) {
  return AnimatedTextKit(
    animatedTexts: [
      ColorizeAnimatedText(
        text,
        textStyle: GoogleFonts.robotoSlab(
          fontWeight: fontWeight,
          fontSize: fontSize,
        ),
        colors: colors ?? [
          Colors.white,
          Color.fromARGB(255, 170, 170, 170), // Mid-tone gray for smooth transition
          Color.fromARGB(255, 0, 0, 0),
          Color.fromARGB(255, 170, 170, 170), // Mid-tone gray
          Colors.white, // Back to white
        ],
        speed: duration,
      ),
    ],
    isRepeatingAnimation: true,
    repeatForever: true,
    pause: Duration(milliseconds: 0), // Small pause for smoother effect
  );
}
