import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_provider.dart';
import 'package:goal_tracker/widgets/calendar_tile.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _focusedDay = DateTime.now();
  List<Goal> _goals = [];
  int _currentGoalIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    _goals = await GoalProvider.instance.fetchGoals();
    setState(() {});
  }

  bool _isCurrentDay(DateTime day) {
    return day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Month View'),
      ),
      body: Column(
        children: [
          // Display the title of the current goal
          Text(
            _goals.isNotEmpty ? _goals[_currentGoalIndex].title : 'No Goals Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            headerVisible: true,
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay.isAfter(DateTime.now())) return;
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return CalendarTile(
                  date: day,
                  isDone: _goals.isNotEmpty ? (_goals[_currentGoalIndex].progress[day] ?? false) : false,
                  isCurrentDay: _isCurrentDay(day),
                  onMarkChanged: (isChecked) {
                    if (_goals.isNotEmpty) {
                      setState(() {
                        _goals[_currentGoalIndex].progress[day] = isChecked ?? false;
                        GoalProvider.instance.updateGoalProgress(_goals[_currentGoalIndex].id!, day, isChecked ?? false);
                      });
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      _currentGoalIndex = (_currentGoalIndex - 1 + _goals.length) % _goals.length;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      _currentGoalIndex = (_currentGoalIndex + 1) % _goals.length;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
