class GoalStatus {
  int? id;
  int goalId;
  String date; // Stored as 'YYYY-MM-DD'
  int status; // 1: Done, 0: Not done, -1: Blank

  GoalStatus({
    this.id,
    required this.goalId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'date': date,
      'status': status,
    };
  }

  static GoalStatus fromMap(Map<String, dynamic> map) {
    return GoalStatus(
      id: map['id'] as int?,
      goalId: map['goal_id'] ?? 0,
      date: map['date'] ?? '',
      status: map['status'] ?? -1,
    );
  }
}
