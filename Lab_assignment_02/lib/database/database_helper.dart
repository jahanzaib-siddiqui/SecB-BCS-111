import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_result.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'number_game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guessed_number INTEGER NOT NULL,
        target_number INTEGER NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertGameResult(GameResult result) async {
    final db = await database;
    return await db.insert('game_results', result.toMap());
  }

  Future<List<GameResult>> getAllGameResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_results',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => GameResult.fromMap(maps[i]));
  }

  Future<int> deleteAllGameResults() async {
    final db = await database;
    return await db.delete('game_results');
  }

  Future<int> deleteGameResult(int id) async {
    final db = await database;
    return await db.delete('game_results', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getGameStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results'),
    ) ?? 0;
    final correct = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM game_results WHERE status = 'Correct!'"),
    ) ?? 0;
    return {'total': total, 'correct': correct};
  }
}
