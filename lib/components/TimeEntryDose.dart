
class TimeEntryDose {
  String time;
  double dosage;

  TimeEntryDose({
    required this.time,
    required this.dosage,
  });

  // Convert a TimeEntryDose object into a map
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'dosage': dosage,
    };
  }

  // Create a TimeEntryDose object from a map
  factory TimeEntryDose.fromMap(Map<String, dynamic> map) {
    return TimeEntryDose(
      time: map['time'] ?? '',
      dosage: map['dosage']?.toDouble() ?? 0.0,
    );
  }
}