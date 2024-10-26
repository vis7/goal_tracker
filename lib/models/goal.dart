// lib/models/goal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Goal {
  int? id;
  String title;
  String description;
  List<bool> daysOfWeek; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  DateTime startDate;
  DateTime? endDate; // Nullable, if goal is forever
  int? eventCount; // Nullable, if goal is not limited by events
  TimeOfDay? time; // Nullable, if no specific time
  int? reminderMinutes; // Nullable, if no reminder

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    this.eventCount,
    this.time,
    this.reminderMinutes,
  });

  factory Goal.fromMap(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        daysOfWeek:
            (json['daysOfWeek'] as String).split(',').map((e) => e == '1').toList(),
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        eventCount: json['eventCount'],
        time: json['time'] != null
            ? TimeOfDay(
                hour: int.parse(json['time'].split(':')[0]),
                minute: int.parse(json['time'].split(':')[1]),
              )
            : null,
        reminderMinutes: json['reminderMinutes'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'daysOfWeek': daysOfWeek.map((e) => e ? '1' : '0').join(','),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'eventCount': eventCount,
        'time': time != null
            ? '${time!.hour.toString().padLeft(2, '0')}:'
              '${time!.minute.toString().padLeft(2, '0')}'
            : null,
        'reminderMinutes': reminderMinutes,
      };
}
