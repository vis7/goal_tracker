import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/goal.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'goals.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            daysTracking TEXT
          )
        ''');
      },
    );
  }

  // Insert a new goal
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toJson());
  }

  // Fetch all goals
  Future<List<Goal>> fetchGoals() async {
    final db = await database;
    final result = await db.query('goals');
    return result.map((json) => Goal.fromJson(json)).toList();
  }

  // Update goal day tracking
  Future<int> updateGoalDayTracking(int id, Map<String, String> daysTracking) async {
    final db = await database;
    return await db.update(
      'goals',
      {'daysTracking': Goal.encodeDaysTracking(daysTracking)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a goal
  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}
