import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/screens/goal_detail_screen.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;

  GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(goal.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(goal.description),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal)),
        );
      },
    );
  }
}
