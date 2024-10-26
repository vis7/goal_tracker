// lib/screens/week_view_screen.dart
import 'package:flutter/material.dart';
import 'package:goal_tracker/database/db_helper.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_status.dart';
import 'package:goal_tracker/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  List<Goal> _goals = [];
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    _fetchGoals();
  }

  DateTime _getStartOfWeek(DateTime date) {
    int weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  Future<void> _fetchGoals() async {
    final goals = await DBHelper.instance.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _toggleGoalStatus(Goal goal, DateTime date) async {
    if (date.isAfter(DateTime.now())) {
      // Cannot mark future dates
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot mark future dates")),
      );
      return;
    }

    GoalStatus? status = await DBHelper.instance.getGoalStatus(goal.id!, date);
    if (status == null) {
      // Insert new status as done
      await DBHelper.instance.insertGoalStatus(GoalStatus(
        goalId: goal.id!,
        date: date,
        isDone: true,
      ));
    } else {
      // Toggle status
      status.isDone = !status.isDone;
      await DBHelper.instance.updateGoalStatus(status);
    }
    setState(() {});
  }

  Widget _buildGoalRow(Goal goal) {
    return FutureBuilder<List<GoalStatus>>(
      future: DBHelper.instance.getGoalStatuses(
        goal.id!,
        _currentWeekStart,
        _currentWeekStart.add(Duration(days: 6)),
      ),
      builder: (context, snapshot) {
        List<GoalStatus> statuses = snapshot.data ?? [];
        Map<String, bool> statusMap = {
          for (var status in statuses)
            DateFormat('yyyy-MM-dd').format(status.date): status.isDone
        };
        return Row(
          children: [
            Expanded(child: Text(goal.title)),
            ...List.generate(7, (index) {
              DateTime date = _currentWeekStart.add(Duration(days: index));
              bool isToday = DateTime.now().difference(date).inDays == 0 &&
                  DateTime.now().day == date.day;
              bool isFuture = date.isAfter(DateTime.now());
              String dateKey = DateFormat('yyyy-MM-dd').format(date);
              bool isDone = statusMap[dateKey] ?? false;
              bool isGoalDay = goal.daysOfWeek[index];

              return Expanded(
                child: GestureDetector(
                  onTap: isGoalDay
                      ? () => _toggleGoalStatus(goal, date)
                      : null,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green : Colors.grey[200],
                      border: Border.all(
                        color: isToday ? Colors.blue : Colors.grey,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    height: 50,
                    child: Center(
                      child: Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isFuture
                              ? Colors.grey
                              : isDone
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _navigateWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * offset));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Week View')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _navigateWeek(-1),
                icon: Icon(Icons.arrow_left),
              ),
              Text(
                'Week of ${DateFormat('MMM dd').format(_currentWeekStart)}',
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => _navigateWeek(1),
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return _buildGoalRow(_goals[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add goal screen
          Navigator.pushNamed(context, '/add_goal');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
