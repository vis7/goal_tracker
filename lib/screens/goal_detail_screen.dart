import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              _onDaySelected(selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                String? status = widget.goal.daysTracking[day.toIso8601String().split('T')[0]];
                if (status == 'yes') {
                  return Icon(Icons.check, color: Colors.green);
                } else if (status == 'no') {
                  return Icon(Icons.close, color: Colors.red);
                }
                return null; // No marker for unmarked days
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Select a day to mark progress or view goal status'),
            ),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime day) {
    String formattedDate = day.toIso8601String().split('T')[0];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark progress for $formattedDate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  widget.goal.daysTracking[formattedDate] = 'yes';
                  await DatabaseHelper().updateGoal(widget.goal);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Achieved'),
              ),
              ElevatedButton(
                onPressed: () async {
                  widget.goal.daysTracking[formattedDate] = 'no';
                  await DatabaseHelper().updateGoal(widget.goal);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Missed'),
              ),
              ElevatedButton(
                onPressed: () async {
                  widget.goal.daysTracking[formattedDate] = null; // Unmarked
                  await DatabaseHelper().updateGoal(widget.goal);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Clear Mark'),
              ),
            ],
          ),
        );
      },
    );
  }
}
