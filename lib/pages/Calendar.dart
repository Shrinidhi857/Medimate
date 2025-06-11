import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, dynamic> _medicationsForDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMedicationsForDate(_selectedDay!);
  }

  void _fetchMedicationsForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    String dateKey = DateFormat('yyyy-MM-dd').format(date);

    final databaseRef = FirebaseDatabase.instance.ref("users/$userId/calendar/$dateKey");
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> tempMap = {};
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((time, medicationsAtTime) {
        final medsMap = Map<String, dynamic>.from(medicationsAtTime);
        medsMap.forEach((medName, medData) {
          final medDetails = Map<String, dynamic>.from(medData);
          bool taken = medDetails['checked'] ?? false;

          tempMap["$time - $medName"] = {
            'time': time,
            'name': medName,
            'taken': taken,
          };
        });
      });

      setState(() {
        _medicationsForDay = tempMap;
      });
    } else {
      setState(() {
        _medicationsForDay = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchMedicationsForDate(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _medicationsForDay.isEmpty
                    ? Center(child: Text("No Medications for this day."))
                    : ListView.builder(
                  itemCount: _medicationsForDay.length,
                  itemBuilder: (context, index) {
                    String key = _medicationsForDay.keys.elementAt(index);
                    Map med = _medicationsForDay[key];
                    bool taken = med['taken'];
                    String name = med['name'];
                    String time = med['time'];

                    return ListTile(
                      leading: Icon(
                        taken ? Icons.check_circle : Icons.cancel,
                        color: taken ? Colors.green : Colors.red,
                      ),
                      title: Text(name),
                      subtitle: Text("Scheduled at: $time"),
                      trailing: Text(taken ? "Taken" : "Missed"),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
