class Goal {
  final int? id;
  final String title;
  final String description;
  final List<int> daysOfWeek;
  final Map<DateTime, bool> progress;

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysOfWeek': daysOfWeek.join(','),
      'progress': progress.entries.map((e) => '${e.key.toIso8601String()}:${e.value}').join(','),
    };
  }

  // From Map function to be implemented
}
