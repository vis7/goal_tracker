// lib/screens/goal_create_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';

class GoalCreateScreen extends StatefulWidget {
  @override
  _GoalCreateScreenState createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends State<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  List<bool> _daysOfWeek = List.filled(7, false);

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Goal goal = Goal(
        title: _title,
        description: _description,
        daysOfWeek: _daysOfWeek,
      );
      await DBHelper.instance.insertGoal(goal);
      Navigator.pop(context);
    }
  }

  Widget _buildDayCheckbox(String label, int index) {
    return CheckboxListTile(
      title: Text(label),
      value: _daysOfWeek[index],
      onChanged: (bool? value) {
        setState(() {
          _daysOfWeek[index] = value ?? false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Goal'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveGoal,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Goal Title
              TextFormField(
                decoration: InputDecoration(labelText: 'Goal Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              SizedBox(height: 16),
              // Goal Description
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 16),
              // Days of the Week
              Text(
                'Select Days of the Week:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildDayCheckbox('Monday', 0),
              _buildDayCheckbox('Tuesday', 1),
              _buildDayCheckbox('Wednesday', 2),
              _buildDayCheckbox('Thursday', 3),
              _buildDayCheckbox('Friday', 4),
              _buildDayCheckbox('Saturday', 5),
              _buildDayCheckbox('Sunday', 6),
            ],
          ),
        ),
      ),
    );
  }
}
