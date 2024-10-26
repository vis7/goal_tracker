// lib/models/goal_status.dart
class GoalStatus {
  int? id;
  int goalId;
  DateTime date;
  bool isDone;

  GoalStatus({
    this.id,
    required this.goalId,
    required this.date,
    required this.isDone,
  });

  factory GoalStatus.fromMap(Map<String, dynamic> json) => GoalStatus(
        id: json['id'],
        goalId: json['goalId'],
        date: DateTime.parse(json['date']),
        isDone: json['isDone'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'goalId': goalId,
        'date': date.toIso8601String(),
        'isDone': isDone ? 1 : 0,
      };
}
