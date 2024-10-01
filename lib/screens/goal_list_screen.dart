import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';
import 'add_goal_screen.dart';
import 'week_view_screen.dart';
import 'month_view_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _fetchGoals() async {
    List<Goal> goals = await DatabaseHelper.instance.fetchGoals();
    setState(() {
      _goals = goals;
    });
  }

  void _navigateToAddGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalScreen()),
    );
    _fetchGoals();
  }

  void _navigateToWeekView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WeekViewScreen()),
    );
  }

  void _navigateToMonthView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthViewScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _openFeedback() async {
    // Open email client with predefined email address
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'feedback@example.com',
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      // Could not launch email client
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Ensure no padding at the top
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Goal Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Goal'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToAddGoal();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Detail List View'),
              onTap: () {
                Navigator.pop(context);
                // Since we're already on Detail List View, no need to navigate.
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_view_week),
              title: Text('Week View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToWeekView();
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Month View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToMonthView();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.import_export),
              title: Text('Import/Export Goals'),
              onTap: () {
                Navigator.pop(context);
                // Implement import/export functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                _openFeedback();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          Goal goal = _goals[index];
          return ListTile(
            title: Text(goal.title),
            subtitle: Text(goal.description),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to goal details or editing
            },
          );
        },
      ),
    );
  }
}
