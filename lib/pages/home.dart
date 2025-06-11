import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medimate/components/TimeEntryCheck.dart';
import 'package:medimate/data/databaseDose.dart';
import 'package:medimate/pages/Addmedication.dart';
import '../components/Homepage_medicationtile.dart';
import '../components/medicationChecked.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database

import '../data/firebase_service.dart'; // Import the developer package

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _myBox = Hive.box("mybox");
  MedicationDatabaseDose db = MedicationDatabaseDose();
  String day = DateFormat('EEEE').format(DateTime.now());
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference rtdb = FirebaseDatabase.instance.ref(); // Get Realtime Database reference
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = true;
  bool _nextdose = false;
  Map<String, dynamic>? nextMedicine;
  FirebaseService firebaseService = FirebaseService();
  late List<Map<String, dynamic>> sortedmedication;
  final MedicationDatabaseDose dbdose=MedicationDatabaseDose();
  Key _refreshKey = UniqueKey();
  late AnimationController _rotationController;
  bool isResetting = false; // for rotating refresh button



  void _refreshPage() {
    setState(() {
      _refreshKey = UniqueKey(); // triggers rebuild
    });
  }







  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    db.copyFromDoseToCheck();
    _loadData().then((_) {
      updateCalenderdaylist();
    });

  }



  Future<void> updateRTDBCalendar({
    required String userId,
    required String date,
    required String time,
    required String medicationName,
    required bool isChecked,
  }) async {
    final path = 'users/$userId/calendar/$date/$time/$medicationName';
    await rtdb.child(path).set({'checked': isChecked});
  }




  Future<void> _loadData() async {
    if (userId != null) {
      db.medicationCheckList = await loadMedications(userId!);
      final sortedMedication= await findNextDose(db.medicationCheckList);
      startMedicationTimer(sortedMedication);
      final notTaken = await findNotTaken(sortedMedication);
      setState(() {
        nextMedicine = notTaken;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> saveMedication(String userId, MedicationChecked medication) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('medicationlist')
          .doc(medication.name)
          .set(medication.toMap());

      print("✅ Medication saved to Firestore");
    } catch (e) {
      print("❌ Error saving medication: $e");
    }

  }

  Future<void> deleteMedication(String userId, String medicationName) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('medicationlist')
          .doc(medicationName)
          .delete();

      print("🗑️ Medication deleted from Firestore");
    } catch (e) {
      print("❌ Error deleting medication: $e");
    }

  }

  Future<List<MedicationChecked>> loadMedications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('medicationlist')
          .get();

      return snapshot.docs.map((doc) {
        return MedicationChecked.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print("❌ Error loading medications: $e");
      return [];
    }
  }

  void logout() async {
    FirebaseAuth.instance.signOut();
    await _myBox.clear();
    GoogleSignIn().signOut();
  }

  Future<void> updateIsChecked(
      String userId, String medicationName, int timeIndex, bool newValue) async {
    final docRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('medicationlist')
        .doc(medicationName);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    List<dynamic> timeList = List.from(data['timeIntervals']);

    if (timeIndex < timeList.length) {
      timeList[timeIndex]['isChecked'] = newValue;

      await docRef.update({'timeIntervals': timeList});
      print("☑️ Updated isChecked");
    }

  }

  Future<void> markTaken(
      String userId, String medicationName, int timeIndex, bool newValue) async {
    final docRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('medicationlist')
        .doc(medicationName);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    List<dynamic> timeList = List.from(data['timeIntervals']);

    if (timeIndex < timeList.length) {
      timeList[timeIndex]['isChecked'] = newValue;

      await docRef.update({'timeIntervals': timeList});
      print("☑️ Updated isChecked");
    }


  }

  void checkMedicationReminder(List<Map<String, dynamic>> medications) {
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());

    for (var med in medications) {
      if (med['time'] == currentTime) {
         int len=med['medications'].length;
         String mediname="";
        for(int i=0;i<len;i++)mediname =mediname+" ${med['medications'][i]}";
         AwesomeNotifications().createNotification(
           content: NotificationContent(
             id: 1,
             channelKey: 'medication_reminder',
             title: "Time to Take 💊",
             body: "${mediname}",
           ),
         );
        print("Time to take: ${mediname}");

      }
    }
    print("🔔notificaions created ");
  }
  Timer? _reminderTimer;

  Future<void> startMedicationTimer(List<Map<String, dynamic>> medications) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
    _reminderTimer = Timer.periodic(Duration(minutes: 1), (_) {
      checkMedicationReminder(medications);
      final now = DateTime.now();

      if(now.hour==5 && now.minute==46) reset();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _reminderTimer?.cancel(); // Cancel timer
    super.dispose();
  }



  Future<List<Map<String, dynamic>>> findNextDose(List<MedicationChecked> medicationList) async {
    Map<String, Map<String, dynamic>> groupedMedications = {};

    for (var med in medicationList??[]) {
      for (var tim in med.timeIntervals??[]) {
        if (!groupedMedications.containsKey(tim.time)) {
          groupedMedications[tim.time] = {
            'time': tim.time,
            'taken': tim.isChecked,
            'medications': <String>[]
          };
        }
        groupedMedications[tim.time]!['medications'].add(med.name);
      }
    }

    var sortedKeys = groupedMedications.keys.toList()..sort();
    List<Map<String, dynamic>> sortedMedication = [];

    for (var key in sortedKeys) {
      sortedMedication.add(groupedMedications[key]!);
      print("${groupedMedications[key]}");
    }


    return sortedMedication;
  }

  Future<Map<String, dynamic>?> findNotTaken(List<Map<String, dynamic>> sortedMedication) async {
    for (var item in sortedMedication??[]) {
      if (item['taken'] == false) {
        print("this is the items\n");
        print("$item");
        return {
          'time': item['time'],
          'medications': List<String>.from(item['medications']),
        };
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> markAsTaken(List<Map<String, dynamic>> sortedMedication) async {
    final currentMedi = await findNotTaken(sortedMedication); // ✅ await the async function

    if (currentMedi == null) {
      print("❌ No current medication found.");
      return sortedMedication;
    }

    final List<String> targetMeds = List<String>.from(currentMedi['medications']);
    final String targetTime = currentMedi['time'];

    for (var medi in db.medicationCheckList??[]) {
      if (targetMeds.contains(medi.name)) {
        for (var entry in medi.timeIntervals??[]) {
          if (entry.time == targetTime) {
            entry.isChecked = true;
          }
        }
      }
    }



    // Optional: persist the updated data
    await db.updateDatabase(); // 🔄 Save updated list to Firestore/Hive/RTDB

    return sortedMedication;
  }
  Future<void> updateCalenderdaylist() async{
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final targetTime = nextMedicine?['time'] ?? '';
    final selectedMeds = nextMedicine?['medications'] ?? [];

    for (MedicationChecked medi in db.medicationCheckList){
      for (int i = 0; i < medi.timeIntervals.length; i++) {
        final interval = medi.timeIntervals[i];
          // For other meds and intervals → write their current isChecked value
          await updateRTDBCalendar(
          userId: userId!,
          date: todayDate,
          time: interval.time,
          medicationName: medi.name,
          isChecked: interval.isChecked,
          );
      }
    }
  }
  Future<void> reset()async {
        for (MedicationChecked med in dbdose.medicationCheckList) {
          for (TimeEntryCheck t in med.timeIntervals) {
            t.isChecked = false;
          }
        }

        dbdose.updateDatabase();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Medimate",
          style: GoogleFonts.roboto(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.w900,
            fontSize: 25,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: _isLoading
          ? Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 100,
            ),
          )
          : Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    initialPage: 0,
                    indicatorColor: Colors.blue,
                    indicatorBackgroundColor: Colors.grey,
                    children: [
                      Image.asset('assets/images/sample_image_2.jpg', fit: BoxFit.cover),
                      Image.asset('assets/images/sample_image.png', fit: BoxFit.cover),
                    ],
                    autoPlayInterval: 5000,
                    isLoop: true,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "NEXT DOSE",
                          style: GoogleFonts.roboto(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                       TextButton(onPressed: ()=>{
                        AwesomeNotifications().createNotification(
                            content: NotificationContent(
                            id: 1,
                            channelKey: 'medication_reminder',
                            title: "Notification Tesing ✅",
                            body: "Hello",
                            ),
                          )
                        }
                        , child: Text("•",style: TextStyle(color: Colors.white),)),

                        TextButton(
                          onPressed: isResetting ? null : () async {
                            setState(() {
                              isResetting = true;
                            });
                            _rotationController.repeat();

                            await reset();
                            _refreshPage();

                            _rotationController.stop();
                            setState(() {
                              isResetting = false;
                            });
                          },
                          child: isResetting
                              ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )
                              : Icon(
                            Icons.refresh,
                            size: 30,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        )

                      ],
                    ),
                    // Fixed code: Safely handle the case when nextMedicine or medications is null
                    if (nextMedicine != null && nextMedicine!['medications'] != null)
                      ...List<String>.from(nextMedicine!['medications']).map((medName) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "▶ $medName",
                            style: GoogleFonts.roboto(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          nextMedicine?['time'] ?? "",
                          style: GoogleFonts.roboto(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:  _nextdose ? null : () async{
                            setState(() {
                              _nextdose = true;
                            });

                            await _loadData();
                            await db.loadData();

                            final todayDate =
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                            final targetTime = nextMedicine?['time'] ?? '';
                            final selectedMeds =
                                nextMedicine?['medications'] ?? [];

                            for (MedicationChecked medi in db.medicationCheckList) {
                              for (int i = 0; i < medi.timeIntervals.length; i++) {
                                final interval = medi.timeIntervals[i];

                                if (selectedMeds.contains(medi.name) &&
                                    interval.time == targetTime) {
                                  interval.isChecked = true;
                                  await db.RTDOOR.update({medi.name:true});


                                  await updateIsChecked(
                                      userId!, medi.name, i, true);

                                  await updateRTDBCalendar(
                                    userId: userId!,
                                    date: todayDate,
                                    time: interval.time,
                                    medicationName: medi.name,
                                    isChecked: true,
                                  );
                                } else {
                                  await updateRTDBCalendar(
                                    userId: userId!,
                                    date: todayDate,
                                    time: interval.time,
                                    medicationName: medi.name,
                                    isChecked: interval.isChecked,
                                  );
                                }
                              }
                            }

                            await _loadData(); // refresh nextMedicine

                            setState(() {
                              _nextdose = false; // hide loader
                            });
                            _refreshPage();


                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Medication dispensed!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _nextdose
                              ? SizedBox(
                            width: 25,
                            height: 25,
                            child:CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ): Text("Dispense"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top:5,bottom: 5),
                  child:SizedBox(
                    child: Text("Medication List",
                      style :GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  )
              ),
              // Fixed code: Safely handle the case when db.medicationList is null
              if (db.medicationCheckList != null)
                ...List.generate(db.medicationCheckList.length, (index) {
                  return HomePageMedi(medication: db.medicationCheckList[index], db: db);
                }),
            ],
          ),
        ),
      ),


      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    backgroundColor: Colors.grey,
                    child: user?.photoURL == null ? Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                ),
                Text(
                  user?.displayName ?? "User",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),

                SizedBox(height: 30),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth, size: 20, color: Colors.blue/*Theme.of(context).colorScheme.secondary*/),
                      SizedBox(width: 8),
                      Text("Bluetooth", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                    ],
                  ),
                  onTap:() => Navigator.pushNamed(context, '/bluetooth'),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Calendar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, '/CalendarPage'),
                ),

                SizedBox(height: 30),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Guide", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(context, '/guidepage'),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color:Colors.blue)),
                    ],
                  ),
                  onTap: logout,
                ),


              ],

            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.inversePrimary),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicationPage()),
          ).then((_) => _loadData());
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 1,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}