import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/goal.dart';
import 'models/goal_status.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('goal_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;

    if (Platform.isIOS || Platform.isAndroid) {
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, filePath);
    } else {
      // For desktop platforms
      dbPath = join(await getDatabasesPath(), filePath);
    }

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        days_of_week TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals (id)
      )
    ''');
  }

  // Goal CRUD operations

  // Insert a new goal
  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  // Fetch all goals
  Future<List<Goal>> fetchGoals() async {
    final db = await instance.database;
    final result = await db.query('goals');

    return result.map((map) => Goal.fromMap(map)).toList();
  }

  // Update a goal
  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Delete a goal
  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GoalStatus CRUD operations

  // Insert a new goal status
  Future<int> insertGoalStatus(GoalStatus status) async {
    final db = await instance.database;
    return await db.insert('goal_status', status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch goal status for a specific goal and date
  Future<GoalStatus?> getGoalStatus(int goalId, String date) async {
    final db = await instance.database;
    final result = await db.query(
      'goal_status',
      where: 'goal_id = ? AND date = ?',
      whereArgs: [goalId, date],
    );

    if (result.isNotEmpty) {
      return GoalStatus.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Update goal status
  Future<int> updateGoalStatus(GoalStatus status) async {
    final db = await instance.database;
    return await db.update(
      'goal_status',
      status.toMap(),
      where: 'id = ?',
      whereArgs: [status.id],
    );
  }

  // Fetch all goal statuses for a specific goal
  Future<List<GoalStatus>> fetchGoalStatuses(int goalId) async {
    final db = await instance.database;
    final result = await db.query(
      'goal_status',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );

    return result.map((map) => GoalStatus.fromMap(map)).toList();
  }

  // Fetch goal statuses within a date range
  Future<List<GoalStatus>> fetchGoalStatusesInRange(
      int goalId, DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'goal_status',
      where: 'goal_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        goalId,
        startDate.toIso8601String().split('T').first,
        endDate.toIso8601String().split('T').first
      ],
    );

    return result.map((map) => GoalStatus.fromMap(map)).toList();
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Export and Import functions can be added here
}
