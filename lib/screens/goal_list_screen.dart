import 'package:flutter/material.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_provider.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'package:goal_tracker/widgets/goal_tile.dart';
import 'package:goal_tracker/screens/new_goal_screen.dart';

class GoalListScreen extends StatefulWidget {
  @override
  _GoalListScreenState createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    _goals = await GoalProvider.instance.fetchGoals();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      drawer: Sidebar(),
      body: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          return GoalTile(goal: _goals[index]); // Pass the `Goal` object
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewGoalScreen()),
          ).then((value) => _loadGoals()); // Refresh the list after adding a goal
        },
      ),
    );
  }
}
