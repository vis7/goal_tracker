// lib/screens/month_view_screen.dart
import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_status.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  List<Goal> _goals = [];
  int _currentGoalIndex = 0;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    final goals = await DBHelper.instance.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _toggleGoalStatus(Goal goal, DateTime date) async {
    if (date.isAfter(DateTime.now())) {
      // Cannot mark future dates
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot mark future dates")),
      );
      return;
    }

    GoalStatus? status = await DBHelper.instance.getGoalStatus(goal.id!, date);
    if (status == null) {
      // Insert new status as done
      await DBHelper.instance.insertGoalStatus(GoalStatus(
        goalId: goal.id!,
        date: date,
        isDone: true,
      ));
    } else {
      // Toggle status
      status.isDone = !status.isDone;
      await DBHelper.instance.updateGoalStatus(status);
    }
    setState(() {});
  }

  Widget _buildCalendar(Goal goal) {
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(Container()); // Empty cells before first day
    }

    return FutureBuilder<List<GoalStatus>>(
      future: DBHelper.instance.getGoalStatuses(
        goal.id!,
        firstDayOfMonth,
        DateTime(_currentMonth.year, _currentMonth.month, daysInMonth),
      ),
      builder: (context, snapshot) {
        List<GoalStatus> statuses = snapshot.data ?? [];
        Map<String, bool> statusMap = {
          for (var status in statuses)
            DateFormat('yyyy-MM-dd').format(status.date): status.isDone
        };

        for (int day = 1; day <= daysInMonth; day++) {
          DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
          String dateKey = DateFormat('yyyy-MM-dd').format(date);
          bool isToday = DateTime.now().difference(date).inDays == 0 &&
              DateTime.now().day == date.day &&
              DateTime.now().month == date.month;
          bool isFuture = date.isAfter(DateTime.now());
          bool isDone = statusMap[dateKey] ?? false;
          int weekdayIndex = date.weekday - 1;
          bool isGoalDay = goal.daysOfWeek[weekdayIndex];

          dayWidgets.add(
            GestureDetector(
              onTap: isGoalDay
                  ? () => _toggleGoalStatus(goal, date)
                  : null,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green : Colors.grey[200],
                  border: Border.all(
                    color: isToday ? Colors.blue : Colors.grey,
                    width: isToday ? 2 : 1,
                  ),
                ),
                height: 40,
                width: 40,
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isFuture
                          ? Colors.grey
                          : isDone
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return GridView.count(
          crossAxisCount: 7,
          children: dayWidgets,
          shrinkWrap: true,
        );
      },
    );
  }

  void _changeGoal(int offset) {
    setState(() {
      _currentGoalIndex =
          (_currentGoalIndex + offset + _goals.length) % _goals.length;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Month View')),
        body: Center(child: Text('No goals available')),
      );
    }

    Goal currentGoal = _goals[_currentGoalIndex];

    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Month View')),
      body: Column(
        children: [
          // Goal Title and Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeGoal(-1),
                icon: Icon(Icons.arrow_left),
              ),
              Text(
                currentGoal.title,
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => _changeGoal(1),
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Divider(),
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: Icon(Icons.arrow_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Divider(),
          // Weekday Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    DateFormat('E').format(
                      DateTime(2020, 1, index + 6),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
          // Calendar Grid
          Expanded(
            child: SingleChildScrollView(
              child: _buildCalendar(currentGoal),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add goal screen
          Navigator.pushNamed(context, '/add_goal');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
