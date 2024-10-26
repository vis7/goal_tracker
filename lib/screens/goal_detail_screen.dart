// lib/screens/goal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../database/db_helper.dart';
import 'goal_edit_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  GoalDetailScreen({required this.goal});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _getDaysOfWeek(List<bool> daysOfWeek) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> selectedDays = [];
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (daysOfWeek[i]) {
        selectedDays.add(days[i]);
      }
    }
    return selectedDays.join(', ');
  }

  Future<Map<String, int>> _calculateAchievementCounts() async {
    DateTime endDate = goal.endDate ?? DateTime.now();
    if (endDate.isAfter(DateTime.now())) {
      endDate = DateTime.now();
    }

    int totalPossibleDays = 0;
    int extraDays = 0;
    List<DateTime> allDates = [];
    DateTime currentDate = goal.startDate;

    while (!currentDate.isAfter(endDate)) {
      allDates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }

    for (DateTime date in allDates) {
      int weekdayIndex = (date.weekday - 1) % 7; // Adjust for index starting at 0
      if (goal.daysOfWeek[weekdayIndex]) {
        totalPossibleDays++;
      }
    }

    // Fetch all achievements for the goal
    List<DateTime> achievements = await DBHelper.instance.getAchievementsForGoal(goal.id!);

    int achievedDays = achievements.length;

    // Count extra days (days not in goal.daysOfWeek)
    for (DateTime date in achievements) {
      int weekdayIndex = (date.weekday - 1) % 7;
      if (!goal.daysOfWeek[weekdayIndex]) {
        extraDays++;
      }
    }

    int adjustedTotalPossibleDays = totalPossibleDays + extraDays;

    return {
      'achievedDays': achievedDays,
      'totalPossibleDays': adjustedTotalPossibleDays,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalEditScreen(goal: goal),
                ),
              ).then((_) {
                // Refresh the goal details after editing
                Navigator.pop(context); // Go back to the list after editing
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // Title
            Text(
              goal.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Description
            Text(
              goal.description ?? 'No description provided.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // Start Date
            ListTile(
              title: Text('Start Date'),
              subtitle: Text(_formatDate(goal.startDate)),
            ),
            // End Date
            ListTile(
              title: Text('End Date'),
              subtitle: Text(_formatDate(goal.endDate)),
            ),
            // Days of the Week
            ListTile(
              title: Text('Days of the Week'),
              subtitle: Text(_getDaysOfWeek(goal.daysOfWeek)),
            ),
            // Time
            if (goal.time != null)
              ListTile(
                title: Text('Time'),
                subtitle: Text(goal.time!.format(context)),
              ),
            // Reminder Minutes
            if (goal.reminderMinutes != null)
              ListTile(
                title: Text('Reminder Before (minutes)'),
                subtitle: Text('${goal.reminderMinutes} minutes'),
              ),
            // Achievement Counts
            ListTile(
              title: Text('Achievement Progress'),
              subtitle: FutureBuilder<Map<String, int>>(
                future: _calculateAchievementCounts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int achievedDays = snapshot.data!['achievedDays']!;
                    int totalPossibleDays = snapshot.data!['totalPossibleDays']!;
                    return Text('$achievedDays / $totalPossibleDays days achieved');
                  } else {
                    return Text('Calculating...');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
