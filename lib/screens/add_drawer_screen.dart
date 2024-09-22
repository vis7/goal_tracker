import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/goal.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Goal Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Goal Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final goal = Goal(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  daysTracking: {},
                );
                await DatabaseHelper().insertGoal(goal);
                Navigator.pop(context);
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
