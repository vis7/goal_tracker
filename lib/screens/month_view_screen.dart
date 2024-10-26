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
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot mark future dates")),
      );
      return;
    }

    GoalStatus? status =
        await DBHelper.instance.getGoalStatus(goal.id!, normalizedDate);
    if (status == null) {
      await DBHelper.instance.insertGoalStatus(GoalStatus(
        goalId: goal.id!,
        date: normalizedDate,
        isDone: true,
      ));
    } else {
      if (status.isDone == true) {
        status.isDone = false;
        await DBHelper.instance.updateGoalStatus(status);
      } else if (status.isDone == false) {
        await DBHelper.instance.deleteGoalStatus(status.id!);
      }
    }
    setState(() {});
  }

  void _showAchievementDialog(Goal goal) async {
    int totalPossibleDays = 0;
    int totalAchievedDays = 0;

    DateTime endDate = goal.endDate ?? DateTime.now();
    DateTime date = goal.startDate;
    int eventsLeft = goal.eventCount ?? -1;

    while (date.isBefore(endDate.add(Duration(days: 1)))) {
      int weekdayIndex = date.weekday - 1;
      bool isGoalDay = goal.daysOfWeek[weekdayIndex];

      if (isGoalDay || eventsLeft == 0) {
        totalPossibleDays++;
      }

      GoalStatus? status =
          await DBHelper.instance.getGoalStatus(goal.id!, date);
      if (status != null && status.isDone == true) {
        totalAchievedDays++;
      }

      if (eventsLeft > 0) {
        eventsLeft--;
        if (eventsLeft == 0) break;
      }

      date = date.add(Duration(days: 1));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Achievement'),
          content: Text('You have achieved $totalAchievedDays out of '
              '$totalPossibleDays days.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar(Goal goal) {
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

    return FutureBuilder<List<GoalStatus>>(
      future: DBHelper.instance.getGoalStatuses(
        goal.id!,
        firstDayOfMonth,
        DateTime(_currentMonth.year, _currentMonth.month, daysInMonth),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<GoalStatus> statuses = snapshot.data!;
        Map<String, GoalStatus> statusMap = {
          for (var status in statuses)
            DateFormat('yyyy-MM-dd').format(status.date): status
        };

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
              String dateKey = DateFormat('yyyy-MM-dd').format(date);
              bool isToday = DateTime.now().difference(date).inDays == 0 &&
                  DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year;
              bool isFuture = date.isAfter(DateTime.now());
              GoalStatus? status = statusMap[dateKey];
              bool? isDone = status?.isDone;
              int weekdayIndex = date.weekday - 1;
              bool isGoalDay = goal.daysOfWeek[weekdayIndex];

              Color bgColor;
              Widget content;

              if (isGoalDay) {
                if (isDone == true) {
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
                } else if (isDone == false) {
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
                    onTap: isGoalDay && !isFuture
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

        return Column(children: calendarRows);
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
            // Goal Title and Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeGoal(-1),
                  icon: Icon(Icons.arrow_left),
                ),
                Row(
                  children: [
                    Text(
                      currentGoal.title,
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () => _showAchievementDialog(currentGoal),
                    ),
                  ],
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
          Navigator.pushNamed(context, '/add_goal');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
