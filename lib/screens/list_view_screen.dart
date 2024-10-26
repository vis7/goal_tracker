import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/goal.dart';
import '../services/csv_service.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer
import 'add_goal_screen.dart'; // Import the AddGoalScreen

class ListViewScreen extends StatelessWidget {
  const ListViewScreen({super.key});

  void _exportGoal(Goal goal) async {
    await CsvService().exportGoals([goal]);
    // Show feedback message
  }

  void _deleteGoal(int goalId) async {
    await DatabaseHelper().deleteGoal(goalId);
    // Reload the screen after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed List View'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: const AppDrawer(), // Use the AppDrawer here
      floatingActionButton: FloatingActionButton(
        heroTag: 'list_view_tag',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Goal>>(
        future: DatabaseHelper().fetchGoals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final goals = snapshot.data!;
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return ListTile(
                title: Text(goal.title),
                subtitle: Text(goal.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteGoal(goal.id!);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: () {
                        _exportGoal(goal);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
