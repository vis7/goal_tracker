class Goal {
  int id;
  String title;
  String description;
  List<int> daysOfWeek; // Days selected (1-7 for Mon-Sun)

  Goal({this.id, this.title, this.description, this.daysOfWeek});

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
      id: map['id'],
      title: map['title'],
      description: map['description'],
      daysOfWeek: map['days_of_week']
          .split(',')
          .map<int>((e) => int.parse(e))
          .toList(),
    );
  }
}
