// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/widgets/sidebar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Text('Settings will be available soon.'),
      ),
    );
  }
}
