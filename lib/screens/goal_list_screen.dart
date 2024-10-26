// lib/screens/goal_list_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/widgets/goal_tile.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'goal_detail_screen.dart';

class GoalListScreen extends StatefulWidget {
  @override
  _GoalListScreenState createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  late Future<List<Goal>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _goalsFuture = DBHelper.instance.getGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() {
      _goalsFuture = DBHelper.instance.getGoals();
    });
  }

  Future<void> _deleteGoal(int goalId) async {
    await DBHelper.instance.deleteGoal(goalId);
    _fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
      ),
      drawer: SideBar(), // Include the drawer
      body: FutureBuilder<List<Goal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final goals = snapshot.data!;
            if (goals.isEmpty) {
              return Center(child: Text('No goals available'));
            }
            return ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GoalTile(
                  goal: goal,
                  onDelete: () => _deleteGoal(goal.id!),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_goal',
                      arguments: goal, // Passing the Goal object
                    ).then((_) {
                      // Refresh the goals list after returning
                      _fetchGoals();
                    });
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching goals'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add goal screen
          Navigator.pushNamed(context, '/add_goal').then((_) => _fetchGoals());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
