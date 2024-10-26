import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/goal.dart';

class CsvService {
  // Export goals to CSV
  Future<String> exportGoals(List<Goal> goals) async {
    List<List<String>> rows = [];

    // Add headers
    rows.add(['Goal Title', 'Description', 'Date', 'Status']);

    // Add goal data
    for (var goal in goals) {
      goal.daysTracking.forEach((date, status) {
        rows.add([goal.title, goal.description, date, status ?? '']); // Empty string for unmarked days
      });
    }

    String csvData = const ListToCsvConverter().convert(rows);

    // Save CSV to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/goals.csv';
    final file = File(filePath);
    await file.writeAsString(csvData);

    return filePath;
  }

  // Import goals from CSV (you can extend this further for full functionality)
  Future<void> importGoals(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString();

    List<List<dynamic>> rows = const CsvToListConverter().convert(contents);

    for (var row in rows.skip(1)) { // Skip header row
      String title = row[0];
      String description = row[1];
      String date = row[2];
      String status = row[3];

      // Fetch existing goals or insert new ones based on title
      // Update goal's daysTracking for specific date
      // Handle empty string as `null` for unmarked days
      String? trackedStatus = status.isEmpty ? null : status;

      // Update goal logic goes here
    }
  }
}
