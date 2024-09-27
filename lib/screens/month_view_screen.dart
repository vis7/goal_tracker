import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _focusedDay = DateTime.now();
  Goal _selectedGoal;
  List<Goal> _goals = [];
  Map<DateTime, List> _goalStatuses = {};

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    List<Goal> goals = await DatabaseHelper.instance.fetchGoals();
    setState(() {
      _goals = goals;
      if (_goals.isNotEmpty) _selectedGoal = _goals.first;
      _fetchGoalStatuses();
    });
  }

  Future<void> _fetchGoalStatuses() async {
    // Fetch statuses for the selected goal and month
    // Populate _goalStatuses map
  }

  void _onGoalChanged(Goal goal) {
    setState(() {
      _selectedGoal = goal;
      _fetchGoalStatuses();
    });
  }

  Widget _buildGoalSelector() {
    return DropdownButton<Goal>(
      value: _selectedGoal,
      items: _goals.map((Goal goal) {
        return DropdownMenuItem<Goal>(
          value: goal,
          child: Text(goal.title),
        );
      }).toList(),
      onChanged: _onGoalChanged,
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) => _goalStatuses[day] ?? [],
      onDaySelected: (selectedDay, focusedDay) {
        if (!selectedDay.isAfter(DateTime.now())) {
          // Allow marking status
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Month View'),
        ),
        body: Column(
          children: [
            _buildGoalSelector(),
            Expanded(child: _buildCalendar()),
          ],
        ));
  }
}
