import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medimate/data/databaseDose.dart';
import '../components/TimeEntryCheck.dart'; // assumed to have: String time, bool isChecked
import '../components/medicationChecked.dart';
import 'medicationDose.dart';

class HomePageMedi extends StatefulWidget {
  final MedicationDose medication;
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

  Future<String> findLastDate(int daysToAdd) async {
    DateTime today = DateTime.now();
    DateTime futureDate = today.add(Duration(days: daysToAdd));
    String formattedDate = "${futureDate.year}-${futureDate.month.toString()
        .padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: findLastDate(widget.medication.quantity),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error loading date");
        }

        String date = snapshot.data ?? '';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "💊 ${widget.medication.name}",
                    style: GoogleFonts.roboto(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .inversePrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "$date",
                    style: GoogleFonts.roboto(
                      color: (widget.medication.quantity>0)?Theme.of(context).colorScheme.inversePrimary:
                      Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // List of time intervals with checkboxes
              ...widget.medication.timeIntervals
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                var timeEntry = entry.value;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "⏱️ ${timeEntry.time}",
                      style: GoogleFonts.roboto(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${timeEntry.dosage} mg",
                      style: GoogleFonts.roboto(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary,
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
      },
    );
  }
}