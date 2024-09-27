import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal_status.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Goal>> _events = {};
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    List<Goal> goals = await DatabaseHelper.instance.fetchGoals();
    setState(() {
      _goals = goals;
      _prepareEvents();
    });
  }

  void _prepareEvents() {
    // Prepare events map for TableCalendar
    _events = {};
    _goals.forEach((goal) {
      goal.daysOfWeek.forEach((day) {
        DateTime date = _getNextWeekday(DateTime.now(), day);
        if (_events[date] == null) _events[date] = [];
        _events[date].add(goal);
      });
    });
  }

  DateTime _getNextWeekday(DateTime startDate, int weekday) {
    // Returns the next date for the given weekday
    int daysToAdd = (weekday - startDate.weekday + 7) % 7;
    return startDate.add(Duration(days: daysToAdd));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });
    }
  }

  Future<void> _markGoalStatus(Goal goal, int status) async {
    String dateStr = _selectedDay.toIso8601String().split('T').first;
    GoalStatus goalStatus = await DatabaseHelper.instance
        .getGoalStatus(goal.id, dateStr);

    if (goalStatus == null) {
      // Insert new status
      await DatabaseHelper.instance.insertGoalStatus(
        GoalStatus(
          goalId: goal.id,
          date: dateStr,
          status: status,
        ),
      );
    } else {
      // Update existing status
      goalStatus.status = status;
      await DatabaseHelper.instance.insertGoalStatus(goalStatus);
    }
    setState(() {});
  }

  Widget _buildGoalsList() {
    List<Goal> dayGoals = _events[_selectedDay] ?? [];
    return ListView.builder(
      itemCount: dayGoals.length,
      itemBuilder: (context, index) {
        Goal goal = dayGoals[index];
        return ListTile(
          title: Text(goal.title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _markGoalStatus(goal, 0),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _markGoalStatus(goal, 1),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Week View'),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: (day) => _events[day] ?? [],
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
            Expanded(child: _buildGoalsList()),
          ],
        ));
  }
}
