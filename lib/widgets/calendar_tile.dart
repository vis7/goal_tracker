import 'package:flutter/material.dart';

class CalendarTile extends StatelessWidget {
  final DateTime date;
  final bool isDone;
  final bool isCurrentDay;
  final Function(bool?) onMarkChanged;

  CalendarTile({
    required this.date,
    required this.isDone,
    required this.isCurrentDay,
    required this.onMarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isCurrentDay ? Colors.blueAccent : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrentDay ? Colors.white : Colors.black,
            ),
          ),
          Checkbox(
            value: isDone,
            onChanged: onMarkChanged,
          ),
        ],
      ),
    );
  }
}
