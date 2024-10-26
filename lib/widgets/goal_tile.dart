// lib/widgets/goal_tile.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  GoalTile({
    required this.goal,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(goal.title),
      subtitle: Text(goal.description),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
