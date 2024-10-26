// lib/screens/goal_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // To access flutterLocalNotificationsPlugin
import 'package:timezone/timezone.dart' as tz;

class GoalEditScreen extends StatefulWidget {
  final Goal goal;

  GoalEditScreen({required this.goal});

  @override
  _GoalEditScreenState createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late List<bool> _daysOfWeek;
  late DateTime _startDate;
  DateTime? _endDate;
  int? _eventCount;
  TimeOfDay? _time;
  int? _reminderMinutes;
  late String _durationOption;

  @override
  void initState() {
    super.initState();
    _title = widget.goal.title;
    _description = widget.goal.description ?? '';
    _daysOfWeek = List.from(widget.goal.daysOfWeek);
    _startDate = widget.goal.startDate;
    _endDate = widget.goal.endDate;
    _eventCount = widget.goal.eventCount;
    _time = widget.goal.time;
    _reminderMinutes = widget.goal.reminderMinutes;
    _durationOption = widget.goal.endDate != null
        ? 'Until Date'
        : widget.goal.eventCount != null
            ? 'Event Count'
            : 'Forever';
  }

  void _updateGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Goal updatedGoal = Goal(
        id: widget.goal.id,
        title: _title,
        description: _description,
        daysOfWeek: _daysOfWeek,
        startDate: _startDate,
        endDate: _durationOption == 'Until Date' ? _endDate : null,
        eventCount: _durationOption == 'Event Count' ? _eventCount : null,
        time: _time,
        reminderMinutes: _reminderMinutes,
      );
      await DBHelper.instance.updateGoal(updatedGoal);

      // Cancel existing notifications
      await _cancelExistingNotifications(widget.goal.id!);

      // Schedule new notifications if time and reminder are set
      if (updatedGoal.time != null && updatedGoal.reminderMinutes != null) {
        await _scheduleNotifications(updatedGoal.id!, updatedGoal);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _cancelExistingNotifications(int goalId) async {
    for (int i = 0; i < 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(goalId * 100 + i);
    }
  }

  Future<void> _scheduleNotifications(int goalId, Goal goal) async {
    if (goal.time == null || goal.reminderMinutes == null) return;

    // Iterate through selected days and schedule notifications
    for (int i = 0; i < 7; i++) {
      if (goal.daysOfWeek[i]) {
        // Calculate the next occurrence of the selected weekday
        int daysUntilNext = (i + 1 - DateTime.now().weekday) % 7;
        if (daysUntilNext == 0) {
          // If today is the selected day, check if the time has already passed
          DateTime scheduledTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            goal.time!.hour,
            goal.time!.minute,
          ).subtract(Duration(minutes: goal.reminderMinutes!));
          if (scheduledTime.isBefore(DateTime.now())) {
            daysUntilNext = 7;
          }
        }
        DateTime nextOccurrence =
            DateTime.now().add(Duration(days: daysUntilNext));
        DateTime scheduledDate = DateTime(
          nextOccurrence.year,
          nextOccurrence.month,
          nextOccurrence.day,
          goal.time!.hour,
          goal.time!.minute,
        ).subtract(Duration(minutes: goal.reminderMinutes!));

        // Ensure the scheduled date is in the future
        if (scheduledDate.isBefore(DateTime.now())) {
          scheduledDate = scheduledDate.add(Duration(days: 7));
        }

        // Convert to tz.TZDateTime
        tz.TZDateTime tzScheduledDate =
            tz.TZDateTime.from(scheduledDate, tz.local);

        // Android-specific details
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'goal_tracker_channel', // id
          'Goal Tracker Notifications', // title
          channelDescription: 'Notifications for goal reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        );

        // iOS-specific details
        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails();

        // Overall notification details
        const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        // Schedule the notification weekly
        await flutterLocalNotificationsPlugin.zonedSchedule(
          goalId * 100 + i, // Unique ID for the notification
          'Goal Reminder',
          'It\'s time to work on your goal: ${goal.title}',
          tzScheduledDate,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents:
              DateTimeComponents.dayOfWeekAndTime, // Weekly repeat
        );
      }
    }
  }

  Widget _buildDayCheckbox(String label, int index) {
    return CheckboxListTile(
      title: Text(label),
      value: _daysOfWeek[index],
      onChanged: (bool? value) {
        setState(() {
          _daysOfWeek[index] = value ?? false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Goal'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateGoal,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Goal Title
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Goal Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              SizedBox(height: 16),
              // Goal Description
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 16),
              // Days of the Week
              Text(
                'Select Days of the Week:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildDayCheckbox('Monday', 0),
              _buildDayCheckbox('Tuesday', 1),
              _buildDayCheckbox('Wednesday', 2),
              _buildDayCheckbox('Thursday', 3),
              _buildDayCheckbox('Friday', 4),
              _buildDayCheckbox('Saturday', 5),
              _buildDayCheckbox('Sunday', 6),
              SizedBox(height: 16),
              // Start Date
              ListTile(
                title: Text(
                    'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              // Duration Option
              DropdownButtonFormField<String>(
                value: _durationOption,
                items: ['Forever', 'Until Date', 'Event Count']
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _durationOption = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Goal Duration'),
              ),
              // End Date or Event Count
              if (_durationOption == 'Until Date')
                ListTile(
                  title: Text(_endDate != null
                      ? 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                      : 'Select End Date'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: _startDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                ),
              if (_durationOption == 'Event Count')
                TextFormField(
                  initialValue: _eventCount?.toString(),
                  decoration: InputDecoration(labelText: 'Event Count'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event count';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _eventCount = int.tryParse(value!);
                  },
                ),
              SizedBox(height: 16),
              // Time
              ListTile(
                title: Text(_time != null
                    ? 'Time: ${_time!.format(context)}'
                    : 'Select Time'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _time ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _time = picked;
                    });
                  }
                },
              ),
              // Reminder Minutes
              TextFormField(
                initialValue: _reminderMinutes?.toString(),
                decoration: InputDecoration(
                  labelText: 'Reminder before (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    int? minutes = int.tryParse(value);
                    if (minutes == null || minutes <= 0 || minutes > 120) {
                      return 'Please enter a value between 1 and 120';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  _reminderMinutes = int.tryParse(value!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
