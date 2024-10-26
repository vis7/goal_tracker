import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<bool> _selectedDays = List.generate(7, (_) => false); // Monday to Sunday

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
            const Text('Select Days for Goal:'),
            ToggleButtons(
              isSelected: _selectedDays,
              onPressed: (int index) {
                setState(() {
                  _selectedDays[index] = !_selectedDays[index];
                });
              },
              children: const [
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
                Text('Sat'),
                Text('Sun'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final goal = Goal(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  daysTracking: {}, // Initialize empty tracking map
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
