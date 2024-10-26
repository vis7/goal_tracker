// lib/database/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/goal_status.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'goals.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version to handle migrations
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  void _createDB(Database db, int version) async {
    // Create the 'goals' table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        daysOfWeek TEXT
      )
    ''');

    // Create the 'goal_statuses' table
    await db.execute('''
      CREATE TABLE goal_statuses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        date TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade to version 2: Create the 'goal_statuses' table
      await db.execute('''
        CREATE TABLE goal_statuses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goalId INTEGER NOT NULL,
          date TEXT NOT NULL,
          isDone INTEGER NOT NULL,
          FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
        )
      ''');
    }
    // Handle future upgrades here
  }

  // -------------------- Goal Methods --------------------

  // Insert a new goal into the 'goals' table
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  // Retrieve all goals from the 'goals' table
  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // Update an existing goal in the 'goals' table
  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Delete a goal from the 'goals' table
  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------- GoalStatus Methods --------------------

  // Insert a new goal status into the 'goal_statuses' table
  Future<int> insertGoalStatus(GoalStatus status) async {
    final db = await database;
    return await db.insert('goal_statuses', status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update an existing goal status in the 'goal_statuses' table
  Future<int> updateGoalStatus(GoalStatus status) async {
    final db = await database;
    return await db.update(
      'goal_statuses',
      status.toMap(),
      where: 'id = ?',
      whereArgs: [status.id],
    );
  }

  // Retrieve a specific goal status by goalId and date
  Future<GoalStatus?> getGoalStatus(int goalId, DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goal_statuses',
      where: 'goalId = ? AND date = ?',
      whereArgs: [goalId, date.toIso8601String()],
    );
    if (maps.isNotEmpty) {
      return GoalStatus.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Retrieve all goal statuses for a goal within a date range
  Future<List<GoalStatus>> getGoalStatuses(
      int goalId, DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goal_statuses',
      where: 'goalId = ? AND date BETWEEN ? AND ?',
      whereArgs: [goalId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => GoalStatus.fromMap(maps[i]));
  }
}
