import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/screens/goal_create_screen.dart';
import 'package:goal_tracker/widgets/sidebar.dart';

class GoalListScreen extends StatefulWidget {
  @override
  _GoalListScreenState createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  void _fetchGoals() async {
    final goals = await DBHelper.instance.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Goals')),
      body: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return ListTile(
            title: Text(goal.title),
            subtitle: Text(goal.description),
            onTap: () {
              // Navigate to goal details or edit
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GoalCreateScreen()),
          );
          _fetchGoals();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
