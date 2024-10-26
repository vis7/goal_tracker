// lib/screens/week_view_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_status.dart';
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

  Widget _buildGoalRow(Goal goal) {
    return FutureBuilder<List<GoalStatus>>(
      future: DBHelper.instance.getGoalStatuses(
        goal.id!,
        _currentWeekStart,
        _currentWeekStart.add(Duration(days: 6)),
      ),
      builder: (context, snapshot) {
        List<GoalStatus> statuses = snapshot.data ?? [];
        Map<String, GoalStatus> statusMap = {
          for (var status in statuses)
            DateFormat('yyyy-MM-dd').format(status.date): status
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Title with Achievement Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () => _showAchievementDialog(goal),
                  ),
                ],
              ),
            ),
            // Days Row
            Row(
              children: List.generate(7, (index) {
                DateTime date = _currentWeekStart.add(Duration(days: index));
                String dateKey = DateFormat('yyyy-MM-dd').format(date);
                bool isToday = DateTime.now().difference(date).inDays == 0 &&
                    DateTime.now().day == date.day &&
                    DateTime.now().month == date.month &&
                    DateTime.now().year == date.year;
                bool isFuture = date.isAfter(DateTime.now());
                GoalStatus? status = statusMap[dateKey];
                bool? isDone = status?.isDone;
                bool isGoalDay = goal.daysOfWeek[index];

                Color bgColor;
                Widget content;

                if (isGoalDay) {
                  if (isDone == true) {
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
                  } else if (isDone == false) {
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
