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
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    _fetchGoals();
  }

  DateTime _getStartOfWeek(DateTime date) {
    int weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
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

  Widget _buildGoalRow(Goal goal) {
    // Define goalStartDate here
    DateTime goalStartDate = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );

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
                DateTime date =
                    _currentWeekStart.add(Duration(days: index));
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
                          DateFormat('EEE\nd').format(date),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        Icon(Icons.check, color: Colors.white, size: 16),
                      ],
                    );
                  } else {
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
      },
    );
  }

  void _navigateWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * offset));
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Navigator.pushNamed(context, '/add_goal').then((_) => _fetchGoals());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
