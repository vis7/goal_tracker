import 'dart:convert';

class Goal {
  int? id;
  String title;
  String description;
  Map<String, String> daysTracking; // e.g., {"2023-09-21": "yes", "2023-09-22": "no"}

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.daysTracking,
  });

  // Convert Goal object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysTracking': encodeDaysTracking(daysTracking),
    };
  }

  // Convert JSON (Map) to Goal object
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      daysTracking: decodeDaysTracking(json['daysTracking']),
    );
  }

  // Encode daysTracking to a string (to store in SQLite)
  static String encodeDaysTracking(Map<String, String> daysTracking) {
    return json.encode(daysTracking);
  }

  // Decode daysTracking from a string (retrieved from SQLite)
  static Map<String, String> decodeDaysTracking(String encoded) {
    return Map<String, String>.from(json.decode(encoded));
  }
}
