// lib/database/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/goal_status.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  /// Getter to access the database. Initializes it if not already done.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('goal_tracker.db');
    return _database!;
  }

  /// Initializes the database. Handles migrations if necessary.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, filePath);

    // Open or create the database
    return await openDatabase(
      path,
      version: 2, // Incremented the version for migration
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
        daysOfWeek TEXT NOT NULL, -- Stored as JSON string e.g., "[false, true, ...]"
        startDate TEXT NOT NULL,
        endDate TEXT,
        eventCount INTEGER,
        time TEXT,
        reminderMinutes INTEGER
      )
    ''');

    // Create achievements table with isDone field
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goalId INTEGER NOT NULL,
        date TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 1, -- 1 for true, 0 for false
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Handles database migrations. Adds the isDone column to achievements table.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE achievements ADD COLUMN isDone INTEGER NOT NULL DEFAULT 1
      ''');
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

  /// Marks a goal as achieved on a specific date.
  Future<void> markAchievement(int goalId, DateTime date) async {
    final db = await instance.database;
    await db.insert('achievements', {
      'goalId': goalId,
      'date': date.toIso8601String(),
      'isDone': 1, // 1 represents true
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Unmarks a goal as achieved on a specific date.
  Future<void> unmarkAchievement(int goalId, DateTime date) async {
    final db = await instance.database;
    await db.delete(
      'achievements',
      where: 'goalId = ? AND date = ?',
      whereArgs: [goalId, date.toIso8601String()],
    );
  }

  /// Checks if a goal is marked as achieved on a specific date.
  Future<bool> isAchievementMarked(int goalId, DateTime date) async {
    final db = await instance.database;
    final result = await db.query(
      'achievements',
      where: 'goalId = ? AND date = ?',
      whereArgs: [goalId, date.toIso8601String()],
    );
    return result.isNotEmpty;
  }

  /// Retrieves all achievements for a specific goal.
  Future<List<DateTime>> getAchievementsForGoal(int goalId) async {
    final db = await instance.database;
    final result = await db.query(
      'achievements',
      where: 'goalId = ?',
      whereArgs: [goalId],
    );
    return result.map((json) => DateTime.parse(json['date'] as String)).toList();
  }

  /// Retrieves the count of achievements for a specific goal.
  Future<int> getAchievementCount(int goalId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM achievements WHERE goalId = ?', [goalId]);
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  /// Retrieves all achievements across all goals.
  Future<List<DateTime>> getAllAchievements() async {
    final db = await instance.database;
    final result = await db.query('achievements');
    return result.map((json) => DateTime.parse(json['date'] as String)).toList();
  }

  /// Retrieves the achievement status for a specific goal on a specific date.
  Future<GoalStatus?> getGoalStatus(int goalId, DateTime date) async {
    final db = await instance.database;
    final result = await db.query(
      'achievements',
      where: 'goalId = ? AND date = ?',
      whereArgs: [goalId, date.toIso8601String()],
    );
    if (result.isNotEmpty) {
      return GoalStatus.fromMap(result.first);
    }
    return null;
  }

  /// Inserts a new goal status (achievement) into the database.
  Future<void> insertGoalStatus(GoalStatus status) async {
    final db = await instance.database;
    await db.insert('achievements', status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Updates an existing goal status in the database.
  Future<void> updateGoalStatus(GoalStatus status) async {
    final db = await instance.database;
    if (status.isDone == false) {
      // If isDone is false, delete the achievement
      await db.delete(
        'achievements',
        where: 'id = ?',
        whereArgs: [status.id],
      );
    } else {
      // If isDone is true, ensure the achievement exists
      await db.update(
        'achievements',
        status.toMap(),
        where: 'id = ?',
        whereArgs: [status.id],
      );
    }
  }

  /// Deletes a goal status from the database.
  Future<void> deleteGoalStatus(int id) async {
    final db = await instance.database;
    await db.delete(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Closes the database connection.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
