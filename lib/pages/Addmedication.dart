import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:medimate/components/TimeEntryDose.dart';
import 'package:medimate/components/dialogbox.dart';
import 'package:medimate/data/databaseDose.dart';
import 'package:medimate/data/medicationquantity.dart';
import '../components/medicationDose.dart';
import 'mediTile.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final dbdose = MedicationDatabaseDose();
  final medinamecontroller = TextEditingController();
  final timecontroller = TextEditingController();
  final dosecontroller = TextEditingController();
  final quantitycontroller = TextEditingController();
  final box = Hive.box('mybox');
  bool isLoading = false;
  bool saveloading=false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _initializeData();
  }



  // Initialize data asynchronously
  Future<void> _initializeData() async {
    try {
      // First load the dose data
      await dbdose.loadData();

      // Then initialize the check data based on dose data
      await dbdose.copyFromDoseToCheck();

      // Update UI after data is loaded
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error initializing data: $e");
    }
  }

  // Save a new medication or update an existing one
  void saveMedication() async {
    setState(() {
      saveloading=true;
    });
    if (medinamecontroller.text.trim().isEmpty ||
        timecontroller.text.trim().isEmpty ||
        dosecontroller.text.trim().isEmpty) {
      // Show feedback to user about required fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      String newName = medinamecontroller.text.trim();
      String doseText = dosecontroller.text.trim();
      String newTime = timecontroller.text.trim();
      int quantity = double.tryParse(quantitycontroller.text.trim())?.toInt() ?? 0;
      double dosage = double.tryParse(doseText) ?? 0.0;
      print("quantity:${quantity} ${quantitycontroller.text}");

      // Find if medication already exists
      int existingIndex = dbdose.medicationDoseList.indexWhere((med) => med.name == newName);

      setState(() {
        if (existingIndex != -1) {
          dbdose.medicationDoseList[existingIndex].timeIntervals.add(
            TimeEntryDose(time: newTime, dosage: dosage),
          );
          dbdose.medicationDoseList[existingIndex].quantity += quantity;

          print("🟢 Updated quantity: ${dbdose.medicationDoseList[existingIndex].quantity}");
        } else {
          dbdose.medicationDoseList.add(
            MedicationDose(
              name: newName,
              quantity: quantity,
              timeIntervals: [TimeEntryDose(time: newTime, dosage: dosage)],
            ),
          );
          print("🆕 Added new medication with quantity: $quantity");
        }
      });

      // Update the database
      await dbdose.updateDatabase();

      // Update the medication quantity helper
      await MedicationQuantityHelper.setQuantity(newName, quantity);

      // Generate check entries based on dose entries
      await dbdose.copyFromDoseToCheck();

      // Clear input fields
      medinamecontroller.clear();
      timecontroller.clear();
      dosecontroller.clear();
      quantitycontroller.clear();

      // Close dialog
      setState(() {
        saveloading=false;
      });
      Navigator.of(context).pop();

    } catch (e) {
      print("❌ Error saving medication: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medication: ${e.toString()}')),
      );
    }
  }

  // Delete a medication from all storage locations
  Future<void> deleteMedication(String mediname) async {
    try {
      // Update UI first for responsiveness
      setState(() {
        dbdose.medicationDoseList.removeWhere((med) => med.name == mediname);
      });

      // Delete from Firestore collections
      if (userId != null) {
        // Delete from medication_doses collection
        await dbdose.FIRE
            .collection('Users')
            .doc(userId)
            .collection('medication_doses')
            .doc(mediname)
            .delete();

        // Delete from medicationlist collection
        await dbdose.FIRE
            .collection('Users')
            .doc(userId)
            .collection('medicationlist')
            .doc(mediname)
            .delete();
      }

      // Delete from RTDB
      await dbdose.RTDBD.child(mediname).remove();
      await dbdose.RTDBC.child(mediname).remove();
      await dbdose.RTDOOR.child(mediname).remove();

      // Update Hive
      await dbdose.doseBox.put(
          "MEDIMATE_DOSE",
          dbdose.medicationDoseList.map((med) => med.toMap()).toList()
      );

      // Update medication check list
      dbdose.medicationCheckList.removeWhere((med) => med.name == mediname);
      await dbdose.doseBox.put(
          "MEDIMATE",
          dbdose.medicationCheckList.map((med) => med.toMap()).toList()
      );

      // Update quantity map
      final quantityMap = Map<String, int>.from(
          dbdose.doseBox.get("MED_QUANTITY", defaultValue: {})
      );
      quantityMap.remove(mediname);
      await dbdose.doseBox.put("MED_QUANTITY", quantityMap);

      print("✅ Successfully deleted '$mediname' from all storage locations");
    } catch (e) {
      print("❌ Error deleting medication: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medication: ${e.toString()}')),
      );
    }
  }

  // Show dialog to create new medication
  void createMediItem() {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            // Dialog (back layer)
            DialogBox(
              medinamecontroller: medinamecontroller,
              timecontroller: timecontroller,
              dosecontroller: dosecontroller,
              quantitycontroller: quantitycontroller,
              onSave: saveMedication,
              onCancel: () => Navigator.of(context).pop(),
            ),

            // Loading overlay (front layer)
            if (saveloading)
              Positioned.fill(
                child: Material(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  elevation: 10.0, // Higher elevation to come forward
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "ADD Medication",
          style: GoogleFonts.roboto(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.w900,
            fontSize: 25,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Display medication list
                ...dbdose.medicationDoseList.map((medication) {
                  return Meditile(
                    medication: medication,
                    db: dbdose,
                    onDelete: () => deleteMedication(medication.name),
                  );
                }).toList(),

                // Add button at the end
                if(!isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: createMediItem,
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(350, 80),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 30, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 🔄 Loading animation overlay
          if (isLoading)
          Center(
          child: LoadingAnimationWidget.newtonCradle(
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 100,
            ),
          )
        ],
      ),
    );
  }
}