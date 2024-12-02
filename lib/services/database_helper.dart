import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        preferences TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date TEXT,
        location TEXT,
        description TEXT,
        user_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        event_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE friends (
        user_id INTEGER,
        friend_id INTEGER,
        PRIMARY KEY (user_id, friend_id)
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await database;
    return await db.update('events', event, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getEventsForUser(String friendName) async {
    final db = await database;
    return await db
        .query('events', where: 'user_id = ?', whereArgs: [friendName]);
  }

  Future<int> deleteEvent(int eventId) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('gifts', gift);
  }

  Future<int> updateGift(int id, Map<String, dynamic> gift) async {
    final db = await database;
    return await db.update('gifts', gift, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final db = await database;
    return await db.query('gifts', where: 'event_id = ?', whereArgs: [eventId]);
  }

  Future<List<Map<String, dynamic>>> getPledgedGifts() async {
    final db = await database;
    return await db.query('gifts', where: 'status = ?', whereArgs: ['Pledged']);
  }

  Future<Map<String, dynamic>> getUser() async {
    final db = await database;
    final users = await db.query('users', limit: 1); // Fetch the first user
    return users.isNotEmpty ? users.first : {};
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db
        .update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    final db = await database;
    return await db.query('events', where: 'user_id = ?', whereArgs: [userId]);
  }
}
