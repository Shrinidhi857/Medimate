// firebase_service.dart
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Students');

  Future<void> insertStudentData(Map<String, String> student) async {
    await _dbRef.push().set(student);
  }
}
