import 'package:flutter/material.dart';
import 'package:medimate/data/databaseDose.dart';

import 'TimeEntryDose.dart';

class MedicationDose {
  String name;
  int quantity;
  List<TimeEntryDose> timeIntervals;

  MedicationDose({
    required this.name,
    required this.quantity,
    required this.timeIntervals,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity, // Ensure quantity is explicitly included
      'timeIntervals': timeIntervals.map((entry) => entry.toMap()).toList(),
    };
  }

  factory MedicationDose.fromMap(Map<String, dynamic> map) {
    // Explicitly parse the quantity with a default of 0
    int parsedQuantity = 0;
    if (map['quantity'] != null) {
      if (map['quantity'] is int) {
        parsedQuantity = map['quantity'];
      } else if (map['quantity'] is String) {
        parsedQuantity = int.tryParse(map['quantity']) ?? 0;
      }
    }

    return MedicationDose(
      name: map['name'] ?? '',
      quantity: parsedQuantity,
      timeIntervals: List<TimeEntryDose>.from(
        (map['timeIntervals'] as List? ?? []).map(
              (entry) => TimeEntryDose.fromMap(entry),
        ),
      ),
    );
  }
}