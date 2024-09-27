import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';
import '../widgets/app_drawer.dart';
import 'add_goal_screen.dart';

class MonthViewScreen extends StatefulWidget {
  const MonthViewScreen({super.key});

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _focusedDay = DateTime.now();
  int _currentGoalIndex = 0;
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // Load goals from the database
  Future<void> _loadGoals() async {
    List<Goal> goals = await DatabaseHelper().fetchGoals();
    setState(() {
      _goals = goals;
    });
  }

  // Handle swipe to switch between goals
  void _onSwipeGoal(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      setState(() {
        _currentGoalIndex = (_currentGoalIndex + 1) % _goals.length;
      });
    } else if (details.primaryVelocity! > 0) {
      setState(() {
        _currentGoalIndex = (_currentGoalIndex - 1 + _goals.length) % _goals.length;
      });
    }
  }

  // Handle swipe up/down for month navigation
  void _onSwipeMonth(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      });
    } else if (details.primaryVelocity! > 0) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      });
    }
  }

  // Toggle between done/not done/blank statuses for goals
  void _toggleStatus(Goal goal, DateTime day) async {
    String formattedDay = day.toIso8601String().split('T')[0]; // Format day

    setState(() {
      String? currentStatus = goal.daysTracking[formattedDay];
      if (currentStatus == null || currentStatus == '') {
        goal.daysTracking[formattedDay] = 'yes'; // Mark as done
      } else if (currentStatus == 'yes') {
        goal.daysTracking[formattedDay] = 'no'; // Mark as not done
      } else {
        goal.daysTracking[formattedDay] = ''; // Clear status
      }
    });

    // Update the goal in the database
    await DatabaseHelper().updateGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    Goal currentGoal = _goals[_currentGoalIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Month View'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_goal_month_view',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
          await _loadGoals(); // Refresh goals after adding a new goal
        },
        child: const Icon(Icons.add),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _onSwipeGoal,
        onVerticalDragEnd: _onSwipeMonth,
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            _toggleStatus(currentGoal, selectedDay);
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              String? status = currentGoal.daysTracking[day.toIso8601String().split('T')[0]];
              if (status == 'yes') {
                return const Center(
                  child: Icon(Icons.check, color: Colors.green, size: 20),
                );
              } else if (status == 'no') {
                return const Center(
                  child: Icon(Icons.close, color: Colors.red, size: 20),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
