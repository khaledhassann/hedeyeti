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
        id INTEGER PRIMARY KEY,
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
        category TEXT,
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
        event_id INTEGER,
        pledger_id INTEGER -- New column: links the gift to the user who pledged it
);

    ''');
    await db.execute('''
      CREATE TABLE friends (
        user_id INTEGER,
        friend_id INTEGER,
        PRIMARY KEY (user_id, friend_id)
      )
    ''');
  }

  // Insert Event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  // Update Event
  Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await database;
    return await db.update('events', event, where: 'id = ?', whereArgs: [id]);
  }

  // Fetch Events for a User
  Future<List<Map<String, dynamic>>> getEventsForUser(String friendName) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'user_id = ?',
      whereArgs: [friendName],
    );
    return results.isNotEmpty ? results : []; // Return an empty list if no data
  }

  // Delete Event
  Future<int> deleteEvent(int eventId) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  // Fetch Gifts for an Event
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final db = await database;
    final results = await db.query(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return results.isNotEmpty ? results : []; // Return an empty list if no data
  }

  // Fetch Pledged Gifts
  Future<List<Map<String, dynamic>>> getPledgedGifts() async {
    final db = await database;
    final results = await db.query(
      'gifts',
      where: 'status = ?',
      whereArgs: ['Pledged'],
    );
    return results.isNotEmpty ? results : []; // Return an empty list if no data
  }

  // Fetch User
  Future<Map<String, dynamic>> getUser() async {
    final db = await database;
    final results = await db.query('users', limit: 1); // Assuming one user
    return results.isNotEmpty
        ? results.first
        : {}; // Return empty map if no user
  }

  // Update User
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace on duplicate `id`
    );
  }

  // Fetch User's Events
  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results : []; // Return an empty list if no data
  }

  // Fetch Friends
  Future<List<int>> getFriends(int userId) async {
    final db = await database;
    final results = await db.query(
      'friends',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty
        ? results.map((row) => row['friend_id'] as int).toList()
        : []; // Return an empty list if no data
  }

  // Add Friend
  Future<int> addFriend(int userId, int friendId) async {
    final db = await database;
    return await db.insert(
      'friends',
      {'user_id': userId, 'friend_id': friendId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicate entries
    );
  }

  // Gift manipulation functions

  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('gifts', gift);
  }

  Future<int> updateGift(int id, Map<String, dynamic> gift) async {
    final db = await database;
    return await db.update(
      'gifts',
      gift,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGift(int giftId) async {
    final db = await database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  Future<List<Map<String, dynamic>>> getGiftsPledgedByUser(int userId) async {
    final db = await database;
    return await db.query(
      'gifts',
      where: 'pledger_id = ? AND status = ?',
      whereArgs: [userId, 'Pledged'],
    );
  }

  Future<List<Map<String, dynamic>>> getGiftsPledgedToUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT g.* 
    FROM gifts g
    JOIN events e ON g.event_id = e.id
    WHERE e.user_id = ? AND g.status = 'Pledged';
  ''', [userId]);
  }
}
