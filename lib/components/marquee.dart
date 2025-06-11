import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';


class MarqueeComp extends StatefulWidget{
  final double width;
  final TextStyle? style;
  final String text;

  const MarqueeComp({
    super.key,
    required this.text,
    required this.width,
    this.style,
  });

  @override
  State<MarqueeComp> createState() => _MarqueeCompState();
}

class _MarqueeCompState extends State<MarqueeComp> {
  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: widget.width,
      height: 30,
      child: Marquee(
        text: widget.text,
        style: widget.style ?? DefaultTextStyle.of(context).style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace:10,
        velocity: 30,
        startPadding: 10.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}