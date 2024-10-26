import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/goal_list_screen.dart';
import 'package:goal_tracker/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDB();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: GoalTrackerApp(),
    ),
  );
}

class GoalTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Goal Tracker',
      theme: themeProvider.getTheme(),
      home: GoalListScreen(),
    );
  }
}
