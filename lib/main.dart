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

// Import flutter_local_notifications for handling notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import timezone package
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Initialize the FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database
  await DBHelper.instance.initDB();

  // Initialize time zones
  tz.initializeTimeZones();

  // Initialize notifications
  await _initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: GoalTrackerApp(),
    ),
  );
}

/// Initializes the local notifications plugin with settings for Android, iOS, and Linux.
Future<void> _initializeNotifications() async {
  // Android initialization settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS initialization settings
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      // Handle iOS foreground notification tap
    },
  );

  // Linux initialization settings without defaultIcon
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open',
    // Removed defaultIcon here
  );

  // Overall initialization settings
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    linux: initializationSettingsLinux,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tapped logic here
      String? payload = response.payload;
      if (payload != null) {
        // Navigate to specific screen based on payload if needed
      }
    },
  );

  // Create the notification channel (Android 8.0+)
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'goal_tracker_channel', // id
      'Goal Tracker Notifications', // title
      description: 'Notifications for goal reminders',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
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
        // Add other routes as needed
      },
    );
  }
}
