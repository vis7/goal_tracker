import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';

class AddGoalScreen extends StatefulWidget {
  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  List<bool> _selectedDays = List.generate(7, (index) => false);

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      List<int> daysOfWeek = [];
      for (int i = 0; i < 7; i++) {
        if (_selectedDays[i]) daysOfWeek.add(i + 1);
      }

      Goal newGoal = Goal(
        id: 0, // id will be auto-incremented by the database
        title: _title,
        description: _description,
        daysOfWeek: daysOfWeek,
      );

      await DatabaseHelper.instance.insertGoal(newGoal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Goal'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 20),
              Text('Select Days of the Week'),
              Wrap(
                spacing: 10.0,
                children: List<Widget>.generate(7, (int index) {
                  return ChoiceChip(
                    label: Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                    ),
                    selected: _selectedDays[index],
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGoal,
                child: Text('Save Goal'),
              ),
            ]),
          ),
        ));
  }
}
