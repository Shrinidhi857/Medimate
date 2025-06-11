import 'package:flutter/material.dart';

class MyButtons extends StatelessWidget {
  String text;
  final void Function()? onTap;
  MyButtons({
    super.key,
    required this.text,
    required this.onTap,

  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap ,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(25),
        child: Center(
          child: Text(text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,

            ),
          ),
        ),
      ),
    );
  }

}