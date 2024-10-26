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
      body: _goals.isEmpty
          ? Center(child: Text('No goals added yet.'))
          : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return ListTile(
                  title: Text(goal.title),
                  subtitle: Text(goal.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DBHelper.instance.deleteGoal(goal.id!);
                      _fetchGoals();
                    },
                  ),
                  onTap: () {
                    // You can navigate to a goal detail or edit screen here
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_goal');
          _fetchGoals();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
