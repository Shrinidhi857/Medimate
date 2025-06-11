import 'package:flutter/material.dart';

class PlainTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final Function(String)? onChanged;

  const PlainTextField({
    super.key,
    required this.controller,
    this.hintText = "",
    this.textStyle = const TextStyle(fontSize: 16, color: Colors.black),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.textAlign = TextAlign.start,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        style: textStyle,
        textAlign: textAlign,
        decoration: const InputDecoration(
          border: InputBorder.none, // Removes underline and border
          isDense: true, // Reduces default padding
          contentPadding: EdgeInsets.zero, // Ensures no extra spacing
        ),
        onChanged: onChanged,
      ),
    );
  }
}

