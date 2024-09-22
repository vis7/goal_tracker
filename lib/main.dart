import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/list_view_screen.dart';
import 'screens/week_view_screen.dart';
import 'screens/month_view_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/add_goal_screen.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific SQLite initialization
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // For Android/iOS, it will use the default sqflite database factory

  // Initialize the SQLite database
  await DatabaseHelper().database; // Ensure the database is initialized

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Goal Tracker',
      themeMode: themeProvider.themeMode, // Use system or custom dark mode
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(), // Default screen
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Tracker'),
      ),
      drawer: const AppDrawer(),
      body: const ListViewScreen(), // Default to detailed list view
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Goal Tracker Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Detailed List View'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListViewScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Week View'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WeekViewScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Month View'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MonthViewScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Add Goal'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddGoalScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Send Feedback'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Export Data'),
            onTap: () async {
              // Implement export logic here
            },
          ),
          ListTile(
            title: const Text('Import Data'),
            onTap: () async {
              // Implement import logic here
            },
          ),
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}
