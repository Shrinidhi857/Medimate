import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medimate/data/databaseDose.dart';
import '../components/TimeEntryCheck.dart'; // assumed to have: String time, bool isChecked
import '../components/medicationChecked.dart';

class HomePageMedi extends StatefulWidget {
  final MedicationChecked medication;
  final MedicationDatabaseDose db;

  const HomePageMedi({
    super.key,
    required this.medication,
    required this.db,
  });

  @override
  State<HomePageMedi> createState() => _MeditileState();
}

class _MeditileState extends State<HomePageMedi> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Medication name
          Text(
            "💊 ${widget.medication.name}",
            style: GoogleFonts.roboto(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),

          // List of time intervals with checkboxes
          ...widget.medication.timeIntervals.asMap().entries.map((entry) {
            int index = entry.key;
            var timeEntry = entry.value;

            if (timeEntry is! TimeEntryCheck) return SizedBox(); // skip if not correct type

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "⏱️ ${timeEntry.time}",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),

              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
