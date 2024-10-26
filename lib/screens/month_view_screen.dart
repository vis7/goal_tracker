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

    bool isMarked =
        await DBHelper.instance.isAchievementMarked(goal.id!, normalizedDate);

    if (isMarked) {
      await DBHelper.instance.unmarkAchievement(goal.id!, normalizedDate);
    } else {
      await DBHelper.instance.markAchievement(goal.id!, normalizedDate);
    }

    setState(() {});
  }

  Widget _buildCalendar(Goal goal) {
    // Define goalStartDate here
    DateTime goalStartDate = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );

    int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    DateTime firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];
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

    dayWidgets.add(Row(children: weekdayHeaders));

    int totalCells = ((startingWeekday - 1) + daysInMonth);
    int numRows = (totalCells / 7).ceil();

    return FutureBuilder<List<DateTime>>(
      future: DBHelper.instance.getAchievementsForGoal(goal.id!),
      builder: (context, snapshot) {
        List<DateTime> achievements = snapshot.data ?? [];

        // Calculate total possible days and total achieved days
        DateTime today = DateTime.now();
        DateTime normalizedToday =
            DateTime(today.year, today.month, today.day);
        DateTime endDate = normalizedToday;
        DateTime date = goalStartDate;
        int totalPossibleDays = 0;

        while (date.isBefore(endDate.add(Duration(days: 1)))) {
          totalPossibleDays++;
          date = date.add(Duration(days: 1));
        }

        int totalAchievedDays = achievements
            .where((achievementDate) =>
                !achievementDate.isAfter(normalizedToday) &&
                !achievementDate.isBefore(goalStartDate))
            .length;

        List<Widget> calendarRows = [];
        int dayCounter = 1;

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
              bool isBeforeStartDate =
                  normalizedDate.isBefore(goalStartDate);
              bool isMarked = achievements.any((achievementDate) =>
                  achievementDate == normalizedDate);

              // All days are goal days now
              bool isGoalDay = true;

              Color bgColor;
              Widget content;

              if (isGoalDay) {
                if (isMarked) {
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
                } else {
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
          Navigator.pushNamed(context, '/add_goal').then((_) => _fetchGoals());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
