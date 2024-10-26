// lib/widgets/sidebar.dart

import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Goal Tracker',
                style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Goals'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.view_week),
            title: Text('Week View'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/week_view');
            },
          ),
          ListTile(
            leading: Icon(Icons.view_module),
            title: Text('Month View'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/month_view');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
