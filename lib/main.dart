import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/goal_list_screen.dart';
import 'package:goal_tracker/utils/theme_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Tracker',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: ThemeMode.system,
      home: GoalListScreen(),
    );
  }
}
