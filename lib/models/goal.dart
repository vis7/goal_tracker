class Goal {
  int id;
  String title;
  String description;
  List<int> daysOfWeek; // Days selected (1-7 for Mon-Sun)

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'days_of_week': daysOfWeek.join(','), // Store as CSV
    };
  }

  static Goal fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      daysOfWeek: map['days_of_week'] != null
          ? (map['days_of_week'] as String)
              .split(',')
              .map<int>((e) => int.parse(e))
              .toList()
          : [],
    );
  }
}
