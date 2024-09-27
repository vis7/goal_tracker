import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/goal_list_screen.dart';
import 'utils/theme_provider.dart';

void main() {
  runApp(GoalTrackerApp());
}

class GoalTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'Goal Tracker',
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: GoalListScreen(),
          );
        },
      ),
    );
  }
}
