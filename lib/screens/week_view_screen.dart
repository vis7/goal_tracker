import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/goal_provider.dart';
import 'package:goal_tracker/widgets/calendar_tile.dart';

class WeekViewScreen extends StatefulWidget {
  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  DateTime _focusedDay = DateTime.now();
  List<Goal> _goals = [];

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
        title: Text('Week View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
            selectedDayPredicate: (day) {
              return _isCurrentDay(day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!_isCurrentDay(selectedDay)) return;
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return CalendarTile(
                  date: day,
                  isDone: false, // Placeholder; real status would be fetched from `_goals`
                  isCurrentDay: _isCurrentDay(day),
                  onMarkChanged: (isChecked) {
                    // Update goal progress here
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_goals[index].title),
                  subtitle: Text('Progress: ${_goals[index].progress[_focusedDay] ?? false}'),
                  trailing: Checkbox(
                    value: _goals[index].progress[_focusedDay] ?? false,
                    onChanged: (isChecked) {
                      setState(() {
                        _goals[index].progress[_focusedDay] = isChecked ?? false;
                        GoalProvider.instance.updateGoalProgress(_goals[index].id!, _focusedDay, isChecked ?? false);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
