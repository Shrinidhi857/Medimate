import 'TimeEntryCheck.dart';

class MedicationChecked {
  final String name;
  final List<TimeEntryCheck> timeIntervals; // <-- IMPORTANT

  MedicationChecked({
    required this.name,
    required this.timeIntervals,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'timeIntervals': timeIntervals.map((e) => e.toMap()).toList(),
  };

  factory MedicationChecked.fromMap(Map<String, dynamic> map) => MedicationChecked(
    name: map['name'],
    timeIntervals: (map['timeIntervals'] as List)
        .map((e) => TimeEntryCheck.fromMap(e))
        .toList(),
  );
}
