import 'firebase_service.dart';


class AnotherClass {
  final FirebaseService firebaseService = FirebaseService();

  void insert() {
    Map<String, String> student = {
      'name': 'John',
      'age': '23',
      'salary': '40000'
    };

    firebaseService.insertStudentData(student);
  }
}
