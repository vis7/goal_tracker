import 'package:flutter/material.dart';
import 'package:goal_tracker/widgets/sidebar.dart';

class MonthViewScreen extends StatefulWidget {
  @override
  _MonthViewScreenState createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  // Implement month view logic
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(title: Text('Month View')),
      body: Center(
        child: Text('Month View Content'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add goal screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
