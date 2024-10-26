import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/goal.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';
import 'package:intl/intl.dart';
import '../services/csv_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Goal>> _goalsFuture;
  DateTime _currentDate = DateTime.now();
  DateTime _firstDayOfWeek = DateTime.now();
  DateTime _lastDayOfWeek = DateTime.now();

  @override
  void initState() {
    super.initState();
    _goalsFuture = DatabaseHelper().fetchGoals();
    _calculateWeekRange(_currentDate);
  }

  // Calculate the first and last days of the current week
  void _calculateWeekRange(DateTime date) {
    _firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    _lastDayOfWeek = _firstDayOfWeek.add(const Duration(days: 6));
  }

  // Export goals as CSV
  void _exportGoals() async {
    final goals = await DatabaseHelper().fetchGoals();
    String filePath = await CsvService().exportGoals(goals);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data exported to $filePath')));
  }

  // UI to display goals for the current week with achieved status
  Widget _buildWeekGoalList(List<Goal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Goals for Current Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return ListTile(
              title: Text(goal.title),
              subtitle: Text(_getWeekGoalStatus(goal)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalDetailScreen(goal: goal),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Get goal progress for the current week
  String _getWeekGoalStatus(Goal goal) {
    String status = '';
    for (DateTime day = _firstDayOfWeek; day.isBefore(_lastDayOfWeek.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      String dayStr = DateFormat('yyyy-MM-dd').format(day);
      String? achieved = goal.daysTracking[dayStr];
      status += '\n${DateFormat('EEE, MMM d').format(day)}: ${achieved == 'yes' ? 'Achieved' : achieved == 'no' ? 'Missed' : 'Not Set'}';
    }
    return status;
  }

  // UI to display all goals
  Widget _buildGoalList(List<Goal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return ListTile(
              title: Text(goal.title),
              subtitle: Text(goal.description),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalDetailScreen(goal: goal),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Month-wise goal summary
  Widget _buildMonthFilter() {
    return ElevatedButton(
      onPressed: () {
        showMonthPicker();
      },
      child: const Text('Filter by Month'),
    );
  }

  // Month picker dialog
  void showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Month'),
          content: CalendarDatePicker(
            initialDate: _currentDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onDateChanged: (newDate) {
              setState(() {
                _currentDate = newDate;
              });
            },
            currentDate: _currentDate,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Tracker'),
      ),
      body: FutureBuilder<List<Goal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final goals = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthFilter(),
                  _buildGoalList(goals),         // List of all goals
                  const SizedBox(height: 20),
                  _buildWeekGoalList(goals),     // List of weekly goals with their status
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _exportGoals,      // Export button
                    child: const Text('Export Data'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_view_tag',
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
