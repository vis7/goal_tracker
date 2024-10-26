// lib/screens/week_view_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  List<Goal> _goals = [];
  Map<int, Map<DateTime, int>> _goalAchievements = {};
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    _fetchGoalsAndAchievements();
  }

  DateTime _getStartOfWeek(DateTime date) {
    int weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
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

  Widget _buildGoalRow(Goal goal) {
    DateTime goalStartDate = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );

    Map<DateTime, int> achievements = _goalAchievements[goal.id!] ?? {};

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal Title with Achievement Count
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$totalAchievedDays/$totalPossibleDays',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        // Days Row
        Row(
          children: List.generate(7, (index) {
            DateTime date = _currentWeekStart.add(Duration(days: index));
            DateTime normalizedDate =
                DateTime(date.year, date.month, date.day);
            bool isToday = normalizedDate == normalizedToday;
            bool isFuture = normalizedDate.isAfter(normalizedToday);
            bool isBeforeStartDate = normalizedDate.isBefore(goalStartDate);
            int? status = achievements[normalizedDate];

            // All days are goal days now
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
                      DateFormat('EEE\nd').format(date),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
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
                      DateFormat('EEE\nd').format(date),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    Icon(Icons.close, color: Colors.white, size: 16),
                  ],
                );
              } else {
                // Blank
                bgColor = Colors.grey[200]!;
                content = Text(
                  DateFormat('EEE\nd').format(date),
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  textAlign: TextAlign.center,
                );
              }
            } else {
              bgColor = Colors.grey[300]!;
              content = Text(
                DateFormat('EEE\nd').format(date),
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              );
            }

            return Expanded(
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
                  height: 80,
                  child: Center(child: content),
                ),
              ),
            );
          }),
        ),
        Divider(),
      ],
    );
  }

  void _navigateWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * offset));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Week View')),
      body: Column(
        children: [
          // Week Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _navigateWeek(-1),
                icon: Icon(Icons.arrow_left),
              ),
              Text(
                'Week of ${DateFormat('MMM dd').format(_currentWeekStart)}',
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => _navigateWeek(1),
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Divider(),
          // Goals List
          Expanded(
            child: _goals.isEmpty
                ? Center(child: Text('No goals available'))
                : ListView.builder(
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      return _buildGoalRow(_goals[index]);
                    },
                  ),
          ),
        ],
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
