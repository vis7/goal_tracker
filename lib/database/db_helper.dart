// lib/database/db_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/goal.dart';
import '../models/goal_status.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database
    _database = await _initDB('goals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get the directory for the database
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    // Open or create the database
    return await openDatabase(
      path,
      version: 3, // Ensure the version is set correctly
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the initial database schema.
  Future _createDB(Database db, int version) async {
    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        daysOfWeek TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        eventCount INTEGER,
        time TEXT,
        reminderMinutes INTEGER
      )
    ''');

    // Create goal_status table
    await db.execute('''
      CREATE TABLE goal_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        date TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Helper method to check if a table exists.
  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Helper method to check if a column exists in a table.
  Future<bool> _columnExists(Database db, String tableName, String columnName) async {
    final result = await db.rawQuery("PRAGMA table_info($tableName)");
    for (var row in result) {
      if (row['name'] == columnName) {
        return true;
      }
    }
    return false;
  }

  /// Handles database migrations.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Create goal_status table if it doesn't exist
      if (!await _tableExists(db, 'goal_status')) {
        await db.execute('''
          CREATE TABLE goal_status (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goalId INTEGER NOT NULL,
            date TEXT NOT NULL,
            isDone INTEGER NOT NULL,
            FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
          )
        ''');
      }

      // Add missing columns to goals table
      if (!await _columnExists(db, 'goals', 'daysOfWeek')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN daysOfWeek TEXT NOT NULL DEFAULT '[false,false,false,false,false,false,false]'
        ''');
      }

      if (!await _columnExists(db, 'goals', 'startDate')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN startDate TEXT NOT NULL DEFAULT '${DateTime.now().toIso8601String()}'
        ''');
      }

      if (!await _columnExists(db, 'goals', 'description')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN description TEXT
        ''');
      }

      if (!await _columnExists(db, 'goals', 'endDate')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN endDate TEXT
        ''');
      }

      if (!await _columnExists(db, 'goals', 'eventCount')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN eventCount INTEGER
        ''');
      }

      if (!await _columnExists(db, 'goals', 'time')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN time TEXT
        ''');
      }

      if (!await _columnExists(db, 'goals', 'reminderMinutes')) {
        await db.execute('''
          ALTER TABLE goals ADD COLUMN reminderMinutes INTEGER
        ''');
      }
    }
    // Handle future migrations here
  }

  /// Inserts a new goal into the database.
  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  /// Retrieves all goals from the database.
  Future<List<Goal>> getGoals() async {
    final db = await instance.database;
    final result = await db.query('goals');
    return result.map((json) => Goal.fromMap(json)).toList();
  }

  /// Updates an existing goal in the database.
  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Deletes a goal from the database.
  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Sets the achievement status of a goal on a specific date.
  Future<void> setAchievementStatus(int goalId, DateTime date, int? isDone) async {
    final db = await instance.database;
    if (isDone == null) {
      // Delete the entry (set to blank)
      await db.delete(
        'goal_status',
        where: 'goalId = ? AND date = ?',
        whereArgs: [goalId, date.toIso8601String()],
      );
    } else {
      // Insert or update the entry
      await db.insert('goal_status', {
        'goalId': goalId,
        'date': date.toIso8601String(),
        'isDone': isDone,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Retrieves all achievements for a specific goal.
  Future<Map<DateTime, int>> getAchievementsForGoal(int goalId) async {
    final db = await instance.database;
    final result = await db.query(
      'goal_status',
      where: 'goalId = ?',
      whereArgs: [goalId],
    );
    Map<DateTime, int> statuses = {};
    for (var row in result) {
      DateTime date = DateTime.parse(row['date'] as String);
      int isDone = row['isDone'] as int;
      statuses[date] = isDone;
    }
    return statuses;
  }

  /// Exports all goals and achievements to a CSV file.
  Future<String> exportData() async {
    final goals = await getGoals();
    final db = await instance.database;

    List<String> csvData = [];

    // Add header row for goals
    csvData.add(
        'Goal ID,Title,Description,DaysOfWeek,StartDate,EndDate,EventCount,Time,ReminderMinutes');

    // Add goal data
    for (var goal in goals) {
      String timeString = goal.time != null
          ? '${goal.time!.hour.toString().padLeft(2, '0')}:${goal.time!.minute.toString().padLeft(2, '0')}'
          : '';
      String goalRow =
          '${goal.id},${_escapeCsv(goal.title)},${_escapeCsv(goal.description ?? '')},"${goal.daysOfWeek.map((e) => e ? 1 : 0).join(",")}",${goal.startDate.toIso8601String()},${goal.endDate?.toIso8601String() ?? ''},${goal.eventCount ?? ''},$timeString,${goal.reminderMinutes ?? ''}';
      csvData.add(goalRow);
    }

    // Add a separator between goals and statuses
    csvData.add('---');

    // Add header row for goal_status
    csvData.add('Status ID,Goal ID,Date,IsDone');

    // Add goal_status data
    final statuses = await db.query('goal_status');
    for (var status in statuses) {
      String statusRow =
          '${status['id']},${status['goalId']},${status['date']},${status['isDone']}';
      csvData.add(statusRow);
    }

    return csvData.join('\n');
  }

  /// Imports goals and achievements from a CSV string.
  Future<void> importData(String csvData) async {
    final db = await instance.database;
    List<String> lines = csvData.split('\n');
    int separatorIndex = lines.indexOf('---');

    if (separatorIndex == -1) {
      throw Exception('Invalid CSV format');
    }

    // Start a transaction to ensure data integrity
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('goal_status');
      await txn.delete('goals');

      // Parse goals
      List<String> goalLines = lines.sublist(1, separatorIndex);
      for (var line in goalLines) {
        if (line.trim().isEmpty) continue;
        List<String> fields = _parseCsvLine(line);
        int? goalId = int.tryParse(fields[0]);
        if (goalId == null) continue;

        String title = fields[1];
        String description = fields[2];
        List<bool> daysOfWeek = fields[3]
            .split(',')
            .map((e) => e.trim() == '1')
            .toList();
        DateTime startDate = DateTime.parse(fields[4]);
        DateTime? endDate =
            fields[5].isNotEmpty ? DateTime.parse(fields[5]) : null;
        int? eventCount = int.tryParse(fields[6]);

        // Parse time string to TimeOfDay
        TimeOfDay? time;
        if (fields[7].isNotEmpty) {
          List<String> timeParts = fields[7].split(':');
          if (timeParts.length == 2) {
            int? hour = int.tryParse(timeParts[0]);
            int? minute = int.tryParse(timeParts[1]);
            if (hour != null && minute != null) {
              time = TimeOfDay(hour: hour, minute: minute);
            }
          }
        }

        int? reminderMinutes = int.tryParse(fields[8]);

        Goal goal = Goal(
          id: goalId,
          title: title,
          description: description.isNotEmpty ? description : null,
          daysOfWeek: daysOfWeek,
          startDate: startDate,
          endDate: endDate,
          eventCount: eventCount,
          time: time,
          reminderMinutes: reminderMinutes,
        );

        // Insert the goal into the database
        await txn.insert('goals', goal.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Parse goal_status
      List<String> statusLines = lines.sublist(separatorIndex + 2);
      for (var line in statusLines) {
        if (line.trim().isEmpty) continue;
        List<String> fields = _parseCsvLine(line);
        int? statusId = int.tryParse(fields[0]);
        int? goalId = int.tryParse(fields[1]);
        String date = fields[2];
        int? isDone = int.tryParse(fields[3]);

        if (goalId == null || isDone == null) continue;

        Map<String, dynamic> statusMap = {
          'id': statusId,
          'goalId': goalId,
          'date': date,
          'isDone': isDone,
        };

        await txn.insert('goal_status', statusMap,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  /// Helper method to escape CSV fields
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"')) {
      value = value.replaceAll('"', '""');
      value = '"$value"';
    }
    return value;
  }

  /// Helper method to parse a CSV line
  List<String> _parseCsvLine(String line) {
    List<String> fields = [];
    bool inQuotes = false;
    String field = '';

    for (int i = 0; i < line.length; i++) {
      String char = line[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            field += '"';
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field += char;
        }
      } else {
        if (char == ',') {
          fields.add(field);
          field = '';
        } else if (char == '"') {
          inQuotes = true;
        } else {
          field += char;
        }
      }
    }
    fields.add(field);
    return fields;
  }

  /// Closes the database connection.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
