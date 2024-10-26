import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/goal_create_screen.dart';
import 'package:goal_tracker/screens/goal_list_screen.dart';
import 'package:goal_tracker/screens/month_view_screen.dart';
import 'package:goal_tracker/screens/settings_screen.dart';
import 'package:goal_tracker/screens/week_view_screen.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Goal Tracker', style: TextStyle(fontSize: 24)),
          ),
          ListTile(
            title: Text('Goal List'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GoalListScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Week View'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => WeekViewScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Month View'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MonthViewScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
