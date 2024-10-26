// lib/main.dart

import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/goal_create_screen.dart';
import 'package:goal_tracker/screens/goal_list_screen.dart';
import 'package:goal_tracker/screens/month_view_screen.dart';
import 'package:goal_tracker/screens/settings_screen.dart';
import 'package:goal_tracker/screens/week_view_screen.dart';
import 'package:goal_tracker/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'database/db_helper.dart';
import 'dart:io' show Platform;

// Import sqlite3_flutter_libs to load the necessary SQLite libraries
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// Import sqflite_common_ffi only for desktop platforms
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database
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
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.getThemeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => GoalListScreen(),
        '/add_goal': (context) => GoalCreateScreen(),
        '/week_view': (context) => WeekViewScreen(),
        '/month_view': (context) => MonthViewScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
