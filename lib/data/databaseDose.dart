import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../components/TimeEntryCheck.dart';
import '../components/TimeEntryDose.dart';
import '../components/medicationChecked.dart';
import '../components/medicationDose.dart';
import 'dart:developer' as developer;

class MedicationDatabaseDose {
  List<MedicationDose> medicationDoseList = [];
  List<MedicationChecked> medicationCheckList = [];

  // Firebase initialization
  final FirebaseFirestore FIRE = FirebaseFirestore.instance;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  String get firestoreCollectionPath => "Users/$userId/medication_doses";
  DatabaseReference get RTDBD => FirebaseDatabase.instance.ref().child('users').child(userId ?? 'unknown').child('medication_doses');
  DatabaseReference get RTDBC => FirebaseDatabase.instance.ref().child('users').child(userId ?? 'unknown').child('medicationlist');
  DatabaseReference get RTDOOR => FirebaseDatabase.instance.ref().child('users').child(userId ?? 'unknown').child('door');

  // Hive initialization
  final _doseBox = Hive.box('mybox');
  Box get doseBox => _doseBox;

  // Initialize empty data structures
  Future<void> createInitializeData() async {
    medicationDoseList = [];
    medicationCheckList = [];

    await _doseBox.put("MEDIMATE_DOSE", []);
    await _doseBox.put("MEDIMATE", []);

    developer.log("\n✅ Hive dose list initialized\n", name: 'MedicationDoseDB');
  }

  Future<void> doorClose() async{
    for(MedicationDose med in medicationDoseList){
     await RTDOOR.update({med.name:false});
    }
  }

  // Convert dose data to check data and save it
  Future<void> copyFromDoseToCheck() async {
    await loadData(); // Ensure dose list is loaded
    List<MedicationChecked> convertedList = [];

    for (MedicationDose dose in medicationDoseList) {
      List<TimeEntryCheck> checkIntervals = dose.timeIntervals.map((t) {
        return TimeEntryCheck(
          time: t.time,
          isChecked: false,
        );
      }).toList();

      convertedList.add(MedicationChecked(
        name: dose.name,
        timeIntervals: checkIntervals,
      ));
    }

    // Save locally
    medicationCheckList = convertedList;
    await _doseBox.put("MEDIMATE", medicationCheckList.map((med) => med.toMap()).toList());
    developer.log("✅ Copied from dose to check and saved to Hive", name: 'MedicationDB');

    // Push to remote databases
    await updateDatabase();
  }

  // Helper method to convert TimeEntryDose list to map for RTDB
  Map<String, dynamic> _timeEntryDoseToMap(List<TimeEntryDose> entries) {
    final Map<String, dynamic> result = {};
    for (int i = 0; i < entries.length; i++) {
      result[i.toString()] = entries[i].toMap();
    }
    return result;
  }

  // Helper method to convert TimeEntryCheck list to map for RTDB
  Map<String, dynamic> _timeEntryCheckToMap(List<TimeEntryCheck> entries) {
    final Map<String, dynamic> result = {};
    for (int i = 0; i < entries.length; i++) {
      result[i.toString()] = entries[i].toMap();
    }
    return result;
  }

  // Save data to RTDB helper method for dose data
  Future<void> _saveToRTDBDose(MedicationDose med) async {
    try {
      await RTDBD.child(med.name).set({
        'quantity': med.quantity,
        'timeIntervals': _timeEntryDoseToMap(med.timeIntervals),
      });
      await RTDOOR.update({med.name:false});

      developer.log("✅ RTDB: Dose for '${med.name}' inserted.", name: 'MedicationDoseDB');
    } catch (e) {
      developer.log("❌ RTDB Error for '${med.name}': $e", name: 'MedicationDoseDB');
    }
  }

  // Save data to RTDB helper method for check data
  Future<void> _saveToRTDBCheck(MedicationChecked med) async {
    try {
      await RTDOOR.update({med.name:false});
      await RTDBC.child(med.name).set({
        'timeIntervals': _timeEntryCheckToMap(med.timeIntervals),
      });
      developer.log("✅ RTDB: Medication '${med.name}' with timeIntervals inserted.", name: 'MedicationDoseDB');
    } catch (e) {
      developer.log("❌ RTDB Error for '${med.name}': $e", name: 'MedicationDoseDB');
    }
  }

  // Load all data from local and remote sources
  Future<void> loadData() async {
    // Load dose data from Hive
    await doorClose();
    final rawDose = _doseBox.get("MEDIMATE_DOSE");
    if (rawDose is List) {
      try {
        medicationDoseList = rawDose.map((item) =>
            MedicationDose.fromMap(Map<String, dynamic>.from(item))
        ).toList();
        developer.log("✅ Dose list loaded from Hive", name: 'MedicationDoseDB');
      } catch (e) {
        developer.log("❌ Error parsing Hive dose data: $e", name: 'MedicationDoseDB');
        await createInitializeData();
      }
    } else {
      await createInitializeData();
    }

    // Load check data from Hive
    final rawCheck = _doseBox.get("MEDIMATE");
    if (rawCheck is List) {
      try {
        medicationCheckList = rawCheck.map((item) =>
            MedicationChecked.fromMap(Map<String, dynamic>.from(item))
        ).toList();
        developer.log("✅ MedicationList loaded from Hive", name: 'MedicationDB');
      } catch (e) {
        developer.log("❌ Error parsing Hive check data: $e", name: 'MedicationDB');
        await createInitializeData();
      }
    } else {
      await createInitializeData();
    }

    // If user is logged in, try to load from Firestore/RTDB
    if (userId != null) {
      await _loadFromFirestore();
      await _syncToRTDB();
    }
  }

  // Helper method to load from Firestore
  Future<void> _loadFromFirestore() async {
    try {
      // Load dose data from Firestore
      final doseSnapshot = await FIRE.collection(firestoreCollectionPath).get();
      if (doseSnapshot.docs.isNotEmpty) {
        medicationDoseList = doseSnapshot.docs.map((doc) =>
            MedicationDose.fromMap(doc.data())
        ).toList();

        // Save to Hive
        await _doseBox.put("MEDIMATE_DOSE", medicationDoseList.map((med) => med.toMap()).toList());

        // Save quantity map
        Map<String, int> medNameToQuantity = {
          for (var med in medicationDoseList) med.name: med.quantity,
        };
        await _doseBox.put("MED_QUANTITY", medNameToQuantity);
        developer.log("✅ Dose list loaded from Firestore to Hive", name: 'MedicationDoseDB');
      } else {
        developer.log("ℹ️ Firestore dose data empty, using Hive.", name: 'MedicationDoseDB');
      }

      // Load check data from Firestore
      final checkSnapshot = await FIRE.collection("Users/$userId/medicationlist").get();
      if (checkSnapshot.docs.isNotEmpty) {
        medicationCheckList = checkSnapshot.docs.map((doc) =>
            MedicationChecked.fromMap(doc.data())
        ).toList();

        await _doseBox.put("MEDIMATE", medicationCheckList.map((med) => med.toMap()).toList());
        developer.log("✅ Firestore -> Hive sync done for check data", name: 'MedicationDB');
      } else {
        developer.log("ℹ️ Firestore check data empty, using Hive.", name: 'MedicationDB');
      }
    } catch (e) {
      developer.log("❌ Error loading from Firestore: $e", name: 'MedicationDoseDB');
    }
  }

  // Helper method to sync to RTDB
  Future<void> _syncToRTDB() async {
    try {
      // Sync dose data to RTDB
      for (MedicationDose med in medicationDoseList) {
        await _saveToRTDBDose(med);
      }

      // Sync check data to RTDB
      for (MedicationChecked med in medicationCheckList) {
        await _saveToRTDBCheck(med);
      }
    } catch (e) {
      developer.log("❌ Error syncing to RTDB: $e", name: 'MedicationDoseDB');
    }
  }

  // Update all databases with current data
  Future<void> updateDatabase() async {
    if (userId == null) {
      developer.log("❌ User ID is null, cannot update database.",
          name: 'MedicationDoseDB');
      return;
    }

    try {
      // Debug current quantities
      for (var med in medicationDoseList) {
        developer.log("📊 Medication: ${med.name}, Quantity: ${med.quantity}",
            name: 'MedicationDoseDB');
      }

      // First ensure the MED_QUANTITY data is preserved
      Map<String, int> quantityMap = {};
      for (var med in medicationDoseList) {
        quantityMap[med.name] = med.quantity;
      }
      await _doseBox.put("MED_QUANTITY", quantityMap);
      developer.log("💾 Saved medication quantities to Hive: $quantityMap",
          name: 'MedicationDoseDB');

      // Save dose data to Hive
      await _doseBox.put("MEDIMATE_DOSE",
          medicationDoseList.map((med) => med.toMap()).toList());
      developer.log("✅ Dose list saved to Hive", name: 'MedicationDoseDB');

      // Save check data to Hive
      await _doseBox.put(
          "MEDIMATE", medicationCheckList.map((med) => med.toMap()).toList());
      developer.log("✅ MedicationList saved to Hive", name: 'MedicationDB');

      // Save dose data to Firestore
      final doseBatch = FIRE.batch();
      for (var med in medicationDoseList) {
        final docRef = FIRE.collection(firestoreCollectionPath).doc(med.name);

        // Ensure quantity is properly set in the map
        final medMap = med.toMap();
        medMap['quantity'] =
            med.quantity; // Explicitly ensure quantity is included

        doseBatch.set(docRef, medMap);
        developer.log(
            "🔥 Preparing Firestore data for ${med.name} with quantity ${med
                .quantity}", name: 'MedicationDoseDB');
      }
      await doseBatch.commit();
      developer.log("✅ Dose list saved to Firestore", name: 'MedicationDoseDB');

      // Save check data to Firestore
      final checkBatch = FIRE.batch();
      for (var med in medicationCheckList) {
        final docRef = FIRE.collection("Users/$userId/medicationlist").doc(
            med.name);
        checkBatch.set(docRef, med.toMap());
      }
      await checkBatch.commit();
      developer.log(
          "✅ MedicationList saved to Firestore", name: 'MedicationDB');

      // Save both to RTDB
      await _syncToRTDB();
    } catch (e) {
      developer.log("❌ Error updating database: $e", name: 'MedicationDoseDB');
      throw e; // Re-throw to notify caller about the error
    }
  }}