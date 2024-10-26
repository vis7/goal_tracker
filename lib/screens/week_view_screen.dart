import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/widgets/sidebar.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  // Sample data, replace with actual data from DB
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    // Fetch goals and their statuses for the week
  }

  Widget _buildGoalRow(Goal goal) {
    return Row(
      children: [
        Expanded(child: Text(goal.title)),
        // Build day cells with checkboxes or indicators
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Week View')),
      body: Column(
        children: [
          // Build week calendar header
          Expanded(
            child: ListView.builder(
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
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
