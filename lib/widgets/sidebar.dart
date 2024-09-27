import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/week_view_screen.dart';
import 'package:goal_tracker/screens/month_view_screen.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Goal Tracker')),
          ListTile(
            title: Text('Week View'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => WeekViewScreen()));
            },
          ),
          ListTile(
            title: Text('Month View'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MonthViewScreen()));
            },
          ),
          // More menu items
        ],
      ),
    );
  }
}
