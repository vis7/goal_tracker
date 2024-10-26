// lib/models/goal.dart

import 'dart:convert';
import 'package:flutter/material.dart';

class Goal {
  final int? id;
  final String title;
  final String? description;
  final List<bool> daysOfWeek; // Monday to Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final int? eventCount;
  final TimeOfDay? time;
  final int? reminderMinutes;

  Goal({
    this.id,
    required this.title,
    this.description,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    this.eventCount,
    this.time,
    this.reminderMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysOfWeek': jsonEncode(daysOfWeek),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'eventCount': eventCount,
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'reminderMinutes': reminderMinutes,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    List<dynamic> daysDynamic = jsonDecode(map['daysOfWeek']);
    List<bool> days = daysDynamic.map((e) => e as bool).toList();

    TimeOfDay? time;
    if (map['time'] != null) {
      List<String> parts = (map['time'] as String).split(':');
      if (parts.length == 2) {
        time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      daysOfWeek: days,
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      eventCount: map['eventCount'],
      time: time,
      reminderMinutes: map['reminderMinutes'],
    );
  }
}
