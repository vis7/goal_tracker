// lib/models/goal_status.dart

class GoalStatus {
  final int? id;
  final int goalId;
  final DateTime date;
  bool isDone;

  GoalStatus({
    this.id,
    required this.goalId,
    required this.date,
    this.isDone = true, // Defaults to true when created
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'date': date.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  factory GoalStatus.fromMap(Map<String, dynamic> map) {
    return GoalStatus(
      id: map['id'],
      goalId: map['goalId'],
      date: DateTime.parse(map['date']),
      isDone: map['isDone'] == 1,
    );
  }
}
