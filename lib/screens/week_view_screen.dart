import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';
import '../widgets/app_drawer.dart';
import 'add_goal_screen.dart';

class WeekViewScreen extends StatefulWidget {
  const WeekViewScreen({super.key});

  @override
  State<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDayOfWeek = DateTime.now();
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _calculateFirstDayOfWeek();
  }

  // Load goals from the database
  Future<void> _loadGoals() async {
    List<Goal> goals = await DatabaseHelper().fetchGoals();
    setState(() {
      _goals = goals;
    });
  }

  // Calculate the first day of the current week
  void _calculateFirstDayOfWeek() {
    final today = DateTime.now();
    final firstDay = today.subtract(Duration(days: today.weekday - 1));
    setState(() {
      _firstDayOfWeek = firstDay;
    });
  }

  // Handle swipe to switch between weeks
  void _onSwipeWeek(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      // Swipe left to go to the next week
      setState(() {
        _focusedDay = _focusedDay.add(const Duration(days: 7));
        _calculateFirstDayOfWeek();
      });
    } else if (details.primaryVelocity! > 0) {
      // Swipe right to go to the previous week
      setState(() {
        _focusedDay = _focusedDay.subtract(const Duration(days: 7));
        _calculateFirstDayOfWeek();
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

  // Helper to build a row for each goal's week view
  Widget _buildGoalRow(Goal goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        DateTime day = _firstDayOfWeek.add(Duration(days: index));
        String formattedDay = day.toIso8601String().split('T')[0];
        String? status = goal.daysTracking[formattedDay];

        IconData icon;
        Color color;

        if (status == 'yes') {
          icon = Icons.check;
          color = Colors.green;
        } else if (status == 'no') {
          icon = Icons.close;
          color = Colors.red;
        } else {
          icon = Icons.circle_outlined;
          color = Colors.grey;
        }

        return GestureDetector(
          onTap: () => _toggleStatus(goal, day),
          child: Column(
            children: [
              Text(
                "${day.day}/${day.month}",
                style: const TextStyle(fontSize: 14),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_goals.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week View'),
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
        heroTag: 'add_goal_week_view',
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
        onHorizontalDragEnd: _onSwipeWeek,
        child: Column(
          children: [
            const SizedBox(height: 16), // Add some spacing
            Text(
              "Week of ${_firstDayOfWeek.day}/${_firstDayOfWeek.month}/${_firstDayOfWeek.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  Goal goal = _goals[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildGoalRow(goal), // Build the week row for each goal
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
