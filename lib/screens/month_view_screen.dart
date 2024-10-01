import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal_status.dart';
import 'add_goal_screen.dart';
import 'goal_list_screen.dart';
import 'week_view_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _focusedDay = DateTime.now();
  Goal? _selectedGoal;
  List<Goal> _goals = [];
  Map<DateTime, List<GoalStatus>> _goalStatuses = {};

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    List<Goal> goals = await DatabaseHelper.instance.fetchGoals();
    setState(() {
      _goals = goals;
      if (_goals.isNotEmpty) {
        _selectedGoal = _goals.first;
        _fetchGoalStatuses();
      }
    });
  }

  Future<void> _fetchGoalStatuses() async {
    if (_selectedGoal == null) return;
    List<GoalStatus> statuses =
        await DatabaseHelper.instance.fetchGoalStatuses(_selectedGoal!.id);
    setState(() {
      _goalStatuses = {};
      for (var status in statuses) {
        DateTime date = DateTime.parse(status.date);
        if (_goalStatuses[date] == null) _goalStatuses[date] = [];
        _goalStatuses[date]!.add(status);
      }
    });
  }

  void _onGoalChanged(Goal? goal) {
    setState(() {
      _selectedGoal = goal;
      _fetchGoalStatuses();
    });
  }

  void _navigateToAddGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalScreen()),
    );
    _fetchGoals();
  }

  void _navigateToDetailListView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GoalListScreen()),
    );
  }

  void _navigateToWeekView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WeekViewScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _openFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'feedback@example.com',
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      // Could not launch email client
    }
  }

  Widget _buildGoalSelector() {
    return DropdownButton<Goal>(
      value: _selectedGoal,
      items: _goals.map((Goal goal) {
        return DropdownMenuItem<Goal>(
          value: goal,
          child: Text(goal.title),
        );
      }).toList(),
      onChanged: _onGoalChanged,
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) => _goalStatuses[day] ?? [],
      onDaySelected: (selectedDay, focusedDay) {
        if (!selectedDay.isAfter(DateTime.now())) {
          // Allow marking status
        }
      },
      selectedDayPredicate: (day) => isSameDay(day, DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Month View'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Goal Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Goal'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddGoal();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Detail List View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDetailListView();
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_view_week),
              title: Text('Week View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToWeekView();
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Month View'),
              onTap: () {
                Navigator.pop(context);
                // We're already on Month View
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.import_export),
              title: Text('Import/Export Goals'),
              onTap: () {
                Navigator.pop(context);
                // Implement import/export functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                _openFeedback();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildGoalSelector(),
          Expanded(child: _buildCalendar()),
        ],
      ),
    );
  }
}
