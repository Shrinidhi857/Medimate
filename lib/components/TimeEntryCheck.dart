class TimeEntryCheck {
  final String time;
  bool isChecked;

  TimeEntryCheck({required this.time, this.isChecked = false});

  Map<String, dynamic> toMap() => {
    'time': time,
    'isChecked': isChecked,
  };

  factory TimeEntryCheck.fromMap(Map<String, dynamic> map) => TimeEntryCheck(
    time: map['time'],
    isChecked: map['isChecked'] ?? false,
  );
}