import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/goal.dart';
import 'models/goal_status.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('goal_tracker.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, filePath);

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
  Future<int> insertGoal(Goal goal) async {
    Database db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> fetchGoals() async {
    Database db = await instance.database;
    final maps = await db.query('goals');

    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  // GoalStatus CRUD operations
  Future<int> insertGoalStatus(GoalStatus status) async {
    Database db = await instance.database;
    return await db.insert('goal_status', status.toMap());
  }

  Future<GoalStatus> getGoalStatus(int goalId, String date) async {
    Database db = await instance.database;
    final maps = await db.query('goal_status',
        where: 'goal_id = ? AND date = ?', whereArgs: [goalId, date]);

    if (maps.isNotEmpty) {
      return GoalStatus.fromMap(maps.first);
    }
    return null;
  }

  // Export and Import functions can be added here
}
