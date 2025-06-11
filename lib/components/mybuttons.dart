import 'package:flutter/material.dart';


class MyButton extends StatelessWidget{
  final String text;
  VoidCallback onPressed;
  MyButton({
    super.key,
    required this.text,
    required this.onPressed,
  });


  @override
  Widget build(BuildContext context) {
    return  MaterialButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      color: Theme.of(context).colorScheme.secondary, // Deprecated
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade500,
          width: 1,
        )
        // Fixed
      ),
    );
  }
}