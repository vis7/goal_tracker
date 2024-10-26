// lib/screens/month_view_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  List<Goal> _goals = [];
  Map<int, Map<DateTime, int>> _goalAchievements = {};
  int _currentGoalIndex = 0;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchGoalsAndAchievements();
  }

  Future<void> _fetchGoalsAndAchievements() async {
    final goals = await DBHelper.instance.getGoals();
    Map<int, Map<DateTime, int>> achievements = {};

    for (Goal goal in goals) {
      Map<DateTime, int> goalAchievements =
          await DBHelper.instance.getAchievementsForGoal(goal.id!);
      achievements[goal.id!] = goalAchievements;
    }

    setState(() {
      _goals = goals;
      _goalAchievements = achievements;
    });
  }

  Future<void> _toggleGoalStatus(Goal goal, DateTime date) async {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);
    DateTime goalStartDate = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );

    if (normalizedDate.isAfter(normalizedToday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot mark future dates")),
      );
      return;
    }

    if (normalizedDate.isBefore(goalStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot mark dates before goal start date")),
      );
      return;
    }

    int? currentStatus = _goalAchievements[goal.id!]?[normalizedDate];
    int? newStatus;

    if (currentStatus == null) {
      newStatus = 1; // From blank to done
    } else if (currentStatus == 1) {
      newStatus = 0; // From done to not done
    } else if (currentStatus == 0) {
      newStatus = null; // From not done to blank
    }

    await DBHelper.instance
        .setAchievementStatus(goal.id!, normalizedDate, newStatus);

    if (newStatus == null) {
      _goalAchievements[goal.id!]?.remove(normalizedDate);
    } else {
      _goalAchievements[goal.id!]?[normalizedDate] = newStatus;
    }

    setState(() {});
  }

  Widget _buildCalendar(Goal goal) {
    DateTime goalStartDate = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );

    Map<DateTime, int> achievements = _goalAchievements[goal.id!] ?? {};

    int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    DateTime firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday;

    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);
    DateTime endDate = normalizedToday;
    DateTime date = goalStartDate;
    int totalPossibleDays = 0;

    while (date.isBefore(endDate.add(Duration(days: 1)))) {
      totalPossibleDays++;
      date = date.add(Duration(days: 1));
    }

    int totalAchievedDays = achievements.entries
        .where((entry) =>
            !entry.key.isAfter(normalizedToday) &&
            !entry.key.isBefore(goalStartDate) &&
            entry.value == 1) // Count only 'done' statuses
        .length;

    List<Widget> weekdayHeaders = List.generate(7, (index) {
      return Expanded(
        child: Center(
          child: Text(
            DateFormat('E').format(DateTime(2020, 1, index + 6)),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    });

    List<Widget> calendarRows = [];
    int dayCounter = 1;
    int totalCells = ((startingWeekday - 1) + daysInMonth);
    int numRows = (totalCells / 7).ceil();

    calendarRows.add(Row(children: weekdayHeaders));

    for (int row = 0; row < numRows; row++) {
      List<Widget> weekCells = [];
      for (int col = 0; col < 7; col++) {
        if (row == 0 && col < startingWeekday - 1) {
          weekCells.add(Expanded(child: Container()));
        } else if (dayCounter > daysInMonth) {
          weekCells.add(Expanded(child: Container()));
        } else {
          DateTime date = DateTime(
              _currentMonth.year, _currentMonth.month, dayCounter);
          DateTime normalizedDate =
              DateTime(date.year, date.month, date.day);
          bool isToday = normalizedDate == normalizedToday;
          bool isFuture = normalizedDate.isAfter(normalizedToday);
          bool isBeforeStartDate = normalizedDate.isBefore(goalStartDate);
          int? status = achievements[normalizedDate];

          bool isGoalDay = true;

          Color bgColor;
          Widget content;

          if (isGoalDay) {
            if (status == 1) {
              // Done
              bgColor = Colors.green;
              content = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayCounter',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(Icons.check, color: Colors.white, size: 16),
                ],
              );
            } else if (status == 0) {
              // Not Done
              bgColor = Colors.red;
              content = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayCounter',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(Icons.close, color: Colors.white, size: 16),
                ],
              );
            } else {
              // Blank
              bgColor = Colors.grey[200]!;
              content = Text(
                '$dayCounter',
                style: TextStyle(color: Colors.black),
              );
            }
          } else {
            bgColor = Colors.grey[300]!;
            content = Text(
              '$dayCounter',
              style: TextStyle(color: Colors.grey),
            );
          }

          weekCells.add(
            Expanded(
              child: GestureDetector(
                onTap: !isFuture && !isBeforeStartDate
                    ? () => _toggleGoalStatus(goal, date)
                    : null,
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(
                      color: isToday ? Colors.blue : Colors.grey,
                      width: isToday ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 60,
                  child: Center(child: content),
                ),
              ),
            ),
          );
          dayCounter++;
        }
      }
      calendarRows.add(Row(children: weekCells));
    }

    return Column(
      children: [
        // Achievement Count Display
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${goal.title}: $totalAchievedDays/$totalPossibleDays',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Column(children: calendarRows),
      ],
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Goal Navigation
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
            // Calendar Grid
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _buildCalendar(currentGoal),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add goal screen
          Navigator.pushNamed(context, '/add_goal')
              .then((_) => _fetchGoalsAndAchievements());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
