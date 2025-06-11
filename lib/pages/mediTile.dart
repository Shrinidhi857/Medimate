import 'package:flutter/material.dart';
import 'package:medimate/components/medicationDose.dart';
import 'package:medimate/data/databaseDose.dart';
import '../components/TimeEntryDose.dart';

class Meditile extends StatefulWidget {
  final MedicationDose medication;
  final MedicationDatabaseDose db;
  final VoidCallback onDelete;

  const Meditile({
    super.key,
    required this.medication,
    required this.db,
    required this.onDelete,
  });

  @override
  State<Meditile> createState() => _MeditileState();
}

class _MeditileState extends State<Meditile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete Medication"),
              content: const Text("Are you sure you want to delete this medication?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "💊 ${widget.medication.name} ",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Total:${widget.medication.quantity}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Time Entries
            ...widget.medication.timeIntervals.asMap().entries.map((entry) {
              int index = entry.key;
              TimeEntryDose timeEntry = entry.value;

              // Calculate remaining doses = quantity / total dosage per day
              // This assumes quantity represents total tablets and dosage is tablets per interval
              double remainingDoses = 0;
              if (timeEntry.dosage > 0) {
                remainingDoses = widget.medication.quantity / timeEntry.dosage;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "⏱️ ${timeEntry.time}   Dose: ${timeEntry.dosage}",
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
