import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal_status.dart';
import 'add_goal_screen.dart';
import 'goal_list_screen.dart';
import 'month_view_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Goal>> _events = {};
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    List<Goal> goals = await DatabaseHelper.instance.fetchGoals();
    setState(() {
      _goals = goals;
      _prepareEvents();
    });
  }

  void _prepareEvents() {
    _events = {};
    _goals.forEach((goal) {
      goal.daysOfWeek.forEach((day) {
        DateTime date = _getNextWeekday(_focusedDay, day);
        if (_events[date] == null) _events[date] = [];
        _events[date]!.add(goal);
      });
    });
  }

  DateTime _getNextWeekday(DateTime startDate, int weekday) {
    int daysToAdd = (weekday - startDate.weekday + 7) % 7;
    return startDate.add(Duration(days: daysToAdd));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  Future<void> _markGoalStatus(Goal goal, int status) async {
    if (_selectedDay != null && !_selectedDay!.isAfter(DateTime.now())) {
      String dateStr = _selectedDay!.toIso8601String().split('T').first;
      GoalStatus? goalStatus = await DatabaseHelper.instance
          .getGoalStatus(goal.id, dateStr);

      if (goalStatus == null) {
        await DatabaseHelper.instance.insertGoalStatus(
          GoalStatus(
            goalId: goal.id,
            date: dateStr,
            status: status,
          ),
        );
      } else {
        goalStatus.status = status;
        await DatabaseHelper.instance.updateGoalStatus(goalStatus);
      }
      setState(() {});
    } else {
      // Cannot mark future dates
    }
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

  void _navigateToMonthView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MonthViewScreen()),
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

  Widget _buildGoalsList() {
    if (_selectedDay == null) return Container();
    List<Goal> dayGoals = _events[_selectedDay!] ?? [];
    return ListView.builder(
      itemCount: dayGoals.length,
      itemBuilder: (context, index) {
        Goal goal = dayGoals[index];
        return ListTile(
          title: Text(goal.title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _markGoalStatus(goal, 0),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _markGoalStatus(goal, 1),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Week View'),
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
                // We're already on Week View
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Month View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToMonthView();
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
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: (day) => _events[day] ?? [],
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            availableCalendarFormats: const {
              CalendarFormat.week: 'Week',
            },
          ),
          Expanded(child: _buildGoalsList()),
        ],
      ),
    );
  }
}
