import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';
import '../widgets/app_drawer.dart';

class WeekViewScreen extends StatefulWidget {
  const WeekViewScreen({super.key});

  @override
  State<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  late DateTime startOfWeek;
  late DateTime endOfWeek;
  List<Goal> goals = [];

  @override
  void initState() {
    super.initState();
    _initializeWeekDates();
    _loadGoals();
  }

  void _initializeWeekDates() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    startOfWeek = now.subtract(Duration(days: weekday - 1)); // Monday
    endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday
  }

  Future<void> _loadGoals() async {
    List<Goal> fetchedGoals = await DatabaseHelper().fetchGoals();
    setState(() {
      goals = fetchedGoals;
    });
  }

  bool _canMarkGoal(Goal goal, DateTime date) {
    // Mark goal only for the allowed days (not for future days)
    return date.isBefore(DateTime.now()) || date.isAtSameMomentAs(DateTime.now());
  }

  Widget _buildGoalTile(Goal goal) {
    int completedDays = goal.daysTracking.values.where((done) => done).length;

    return ExpansionTile(
      title: Row(
        children: [
          Expanded(child: Text(goal.title, style: const TextStyle(color: Colors.orange))),
          Text('$completedDays/${goal.daysTracking.length}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
      children: List.generate(7, (index) {
        DateTime currentDay = startOfWeek.add(Duration(days: index));
        bool? isDone = goal.daysTracking[DateFormat('yyyy-MM-dd').format(currentDay)];

        return ListTile(
          title: Text(DateFormat('EEEE, MMM d').format(currentDay)),
          trailing: Checkbox(
            value: isDone ?? false,
            onChanged: _canMarkGoal(goal, currentDay)
                ? (bool? value) {
                    setState(() {
                      goal.daysTracking[DateFormat('yyyy-MM-dd').format(currentDay)] = value!;
                    });
                    DatabaseHelper().updateGoal(goal);
                  }
                : null,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week View'),
      ),
      drawer: const AppDrawer(),
      body: goals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return _buildGoalTile(goals[index]);
              },
            ),
    );
  }
}
