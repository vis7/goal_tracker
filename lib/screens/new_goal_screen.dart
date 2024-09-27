import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal_provider.dart';
import 'package:goal_tracker/models/goal.dart';

class NewGoalScreen extends StatefulWidget {
  @override
  _NewGoalScreenState createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        title: _titleController.text,
        description: _descriptionController.text,
        daysOfWeek: [1, 2, 3, 4, 5], // Example data
        progress: {},
      );
      GoalProvider.instance.insertGoal(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Goal'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: _saveGoal,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
