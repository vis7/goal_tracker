import 'dart:convert';

class Goal {
  int? id;
  String title;
  String description;
  Map<String, String?> daysTracking; // "yes", "no", or null for unmarked days

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
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      daysTracking: decodeDaysTracking(map['daysTracking']),
    );
  }

  // Encode daysTracking to a string (to store in SQLite)
  static String encodeDaysTracking(Map<String, String?> daysTracking) {
    return json.encode(daysTracking);
  }

  // Decode daysTracking from a string (retrieved from SQLite)
  static Map<String, String?> decodeDaysTracking(String encoded) {
    return Map<String, String?>.from(json.decode(encoded));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysTracking': jsonEncode(daysTracking), // Convert map to JSON string
    };
  }
}
