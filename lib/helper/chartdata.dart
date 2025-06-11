import 'package:flutter/material.dart';

class ChartData {
  final int x;
  final double y;
  final String text;
  final Color color;

  ChartData(this.x, this.y, this.text, this.color);
}

final List<ChartData> chartData = [
  ChartData(1924, 90, 'High', Colors.blue),
  ChartData(1925, 50, 'Medium', Colors.green),
  ChartData(1926, 70, 'Low', Colors.red),
  ChartData(1926, 70, 'Low', Colors.yellow),
  ChartData(1926, 70, 'Low', Colors.purple),
  ChartData(1926, 70, 'Low', Colors.orange),
];
