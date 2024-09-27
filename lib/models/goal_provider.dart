import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'goal.dart';

class GoalProvider {
  static Database? _database;
  static final GoalProvider instance = GoalProvider._();

  GoalProvider._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'goal_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            daysOfWeek TEXT,
            progress TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> fetchGoals() async {
    final db = await database;
    final maps = await db.query('goals');
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return Goal(
          id: maps[i]['id'] as int,
          title: maps[i]['title'] as String,
          description: maps[i]['description'] as String,
          daysOfWeek: (maps[i]['daysOfWeek'] as String).split(',').map(int.parse).toList(),
          progress: _parseProgressString(maps[i]['progress'] as String),
        );
      });
    } else {
      return [];
    }
  }

  Future<void> updateGoalProgress(int id, DateTime date, bool isDone) async {
    final db = await database;
    final goals = await fetchGoals();
    final goal = goals.firstWhere((g) => g.id == id);
    goal.progress[date] = isDone;

    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<DateTime, bool> _parseProgressString(String progressString) {
    final progressMap = <DateTime, bool>{};
    final entries = progressString.split(',');
    for (var entry in entries) {
      final parts = entry.split(':');
      final date = DateTime.parse(parts[0]);
      final isDone = parts[1] == 'true';
      progressMap[date] = isDone;
    }
    return progressMap;
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(int id) async {
    final db = await database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
