class Goal {
  int? id;
  String title;
  String description;
  List<bool> daysOfWeek; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
  });

  factory Goal.fromMap(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        daysOfWeek: (json['daysOfWeek'] as String).split(',').map((e) => e == '1').toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'daysOfWeek': daysOfWeek.map((e) => e ? '1' : '0').join(','),
      };
}
