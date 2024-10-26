// lib/database/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/goal_status.dart';
import 'package:intl/intl.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'goals.db');
    return await openDatabase(
      path,
      version: 4, // Incremented to handle schema changes
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        daysOfWeek TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        eventCount INTEGER,
        time TEXT,
        reminderMinutes INTEGER
      )
    ''');

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
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE goals ADD COLUMN startDate TEXT');
      await db.execute('ALTER TABLE goals ADD COLUMN endDate TEXT');
      await db.execute('ALTER TABLE goals ADD COLUMN eventCount INTEGER');
      await db.execute('ALTER TABLE goals ADD COLUMN time TEXT');
      await db.execute('ALTER TABLE goals ADD COLUMN reminderMinutes INTEGER');
    }
    // Handle future upgrades here
  }

  // Goal CRUD methods...

  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // GoalStatus CRUD methods...
  Future<int> insertGoalStatus(GoalStatus status) async {
    final db = await database;
    return await db.insert(
      'goal_statuses',
      status.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGoalStatus(GoalStatus status) async {
    final db = await database;
    return await db.update(
      'goal_statuses',
      status.toMap(),
      where: 'id = ?',
      whereArgs: [status.id],
    );
  }

  Future<int> deleteGoalStatus(int id) async {
    final db = await database;
    return await db.delete(
      'goal_statuses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<GoalStatus?> getGoalStatus(int goalId, DateTime date) async {
    final db = await database;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final List<Map<String, dynamic>> maps = await db.query(
      'goal_statuses',
      where: 'goalId = ? AND date = ?',
      whereArgs: [goalId, formattedDate],
    );
    if (maps.isNotEmpty) {
      return GoalStatus.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<GoalStatus>> getGoalStatuses(
      int goalId, DateTime startDate, DateTime endDate) async {
    final db = await database;
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    final List<Map<String, dynamic>> maps = await db.query(
      'goal_statuses',
      where: 'goalId = ? AND date BETWEEN ? AND ?',
      whereArgs: [goalId, formattedStartDate, formattedEndDate],
    );
    return List.generate(maps.length, (i) => GoalStatus.fromMap(maps[i]));
  }
}
