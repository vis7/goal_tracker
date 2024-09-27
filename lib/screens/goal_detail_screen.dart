import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_provider.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  GoalDetailScreen({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(goal.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            // Display calendar or list of progress here
            Expanded(
              child: ListView.builder(
                itemCount: goal.progress.length,
                itemBuilder: (context, index) {
                  DateTime date = goal.progress.keys.elementAt(index);
                  bool isDone = goal.progress[date] ?? false;
                  return ListTile(
                    title: Text(date.toIso8601String().split('T')[0]),
                    trailing: Checkbox(
                      value: isDone,
                      onChanged: (value) {
                        // Update progress logic
                        GoalProvider.instance.updateGoalProgress(goal.id!, date, value ?? false);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
