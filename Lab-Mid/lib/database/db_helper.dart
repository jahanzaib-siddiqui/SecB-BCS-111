import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 2;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    try {
      // Use Application Support dir — always writable inside macOS sandbox
      final appDir = await getApplicationSupportDirectory();
      final String path = join(appDir.path, 'tasks.db');
      debugPrint('DBHelper: opening DB at $path');
      return await openDatabase(
        path,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        time TEXT DEFAULT '',
        isCompleted INTEGER DEFAULT 0,
        repeat TEXT DEFAULT 'None',
        priority TEXT DEFAULT 'Medium',
        color INTEGER DEFAULT 4284259057,
        subtasks TEXT DEFAULT '',
        subtaskStatus TEXT DEFAULT '',
        extraDates TEXT DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing columns from v1 → v2
      final cols = await db.rawQuery("PRAGMA table_info(tasks)");
      final existing = cols.map((c) => c['name'] as String).toSet();

      if (!existing.contains('time')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN time TEXT DEFAULT ''");
      }
      if (!existing.contains('priority')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT 'Medium'");
      }
      if (!existing.contains('color')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN color INTEGER DEFAULT 4284259057");
      }
      if (!existing.contains('extraDates')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN extraDates TEXT DEFAULT ''");
      }
    }
  }

  Future<int> insert(Task task) async {
    final dbClient = await db;
    return dbClient.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final dbClient = await db;
    final res = await dbClient.query('tasks', orderBy: 'date ASC, time ASC');
    return res.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final dbClient = await db;
    return dbClient.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Task task) async {
    final dbClient = await db;
    final map = task.toMap();
    // Exclude id from the updated values to avoid primary key conflicts
    map.remove('id');
    return dbClient.update('tasks', map,
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteAll() async {
    final dbClient = await db;
    await dbClient.delete('tasks');
  }
}