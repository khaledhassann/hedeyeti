// DatabaseHelper.dart
// THIS FILE WILL HOST ANYTHING RELATED TO THE SQLITE IMPLEMENTATION
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/User.dart';

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
      version: 2, // Incremented version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle migrations
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY, -- Changed from INTEGER to TEXT
        name TEXT,
        email TEXT,
        profilePicture TEXT,
        isMe INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY, -- Changed from INTEGER to TEXT (Firestore Event ID)
        name TEXT,
        date TEXT,
        location TEXT,
        description TEXT,
        category TEXT,
        user_id TEXT, -- Changed from INTEGER to TEXT
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY, -- Changed from INTEGER to TEXT
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        event_id TEXT, -- Changed from INTEGER to TEXT
        pledger_id TEXT, -- Changed from INTEGER to TEXT
        FOREIGN KEY (event_id) REFERENCES events(id),
        FOREIGN KEY (pledger_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE friends (
        user_id TEXT,
        friend_id TEXT,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (friend_id) REFERENCES users(id)
      )
    ''');
  }

  // Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Example migration: Change 'id' fields from INTEGER to TEXT
      // This is a simplified example. In a real-world scenario, data migration would be required.
      // You might need to create new tables, copy data, and rename tables.

      // Create new tables with TEXT IDs
      await db.execute('''
        CREATE TABLE users_new (
          id TEXT PRIMARY KEY,
          name TEXT,
          email TEXT,
          profilePicture TEXT,
          isMe INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE events_new (
          id TEXT PRIMARY KEY,
          name TEXT,
          date TEXT,
          location TEXT,
          description TEXT,
          category TEXT,
          user_id TEXT,
          FOREIGN KEY (user_id) REFERENCES users_new(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE gifts_new (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          category TEXT,
          price REAL,
          status TEXT,
          event_id TEXT,
          pledger_id TEXT,
          FOREIGN KEY (event_id) REFERENCES events_new(id),
          FOREIGN KEY (pledger_id) REFERENCES users_new(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE friends_new (
          user_id TEXT,
          friend_id TEXT,
          PRIMARY KEY (user_id, friend_id),
          FOREIGN KEY (user_id) REFERENCES users_new(id),
          FOREIGN KEY (friend_id) REFERENCES users_new(id)
        )
      ''');

      // Copy data from old tables to new tables
      // This assumes that you have a way to map integer IDs to Firestore string IDs
      // For simplicity, this step is omitted. Implement according to your specific needs.

      // Drop old tables
      await db.execute('DROP TABLE users;');
      await db.execute('DROP TABLE events;');
      await db.execute('DROP TABLE gifts;');
      await db.execute('DROP TABLE friends;');

      // Rename new tables to original names
      await db.execute('ALTER TABLE users_new RENAME TO users;');
      await db.execute('ALTER TABLE events_new RENAME TO events;');
      await db.execute('ALTER TABLE gifts_new RENAME TO gifts;');
      await db.execute('ALTER TABLE friends_new RENAME TO friends;');
    }
    // Handle future migrations here
  }

  // Insert User
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace on duplicate `id`
    );
  }

  // Fetch User by ID
  Future<User?> getUserById(String userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromSQLite(maps.first);
    } else {
      return null;
    }
  }

  // Fetch Logged-In User
  Future<User> getUser() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'isMe = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return User.fromSQLite(results.first);
    } else {
      throw Exception('No logged-in user found in the database.');
    }
  }

  // Update User
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // Insert Event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert(
      'events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update Event
  Future<int> updateEvent(String id, Map<String, dynamic> event) async {
    final db = await database;
    return await db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch Events for a User
  Future<List<Map<String, dynamic>>> getEventsForUser(String userId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results : []; // Return an empty list if no data
  }

  // Delete Event
  Future<int> deleteEvent(String eventId) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  // Fetch Gifts for an Event
  Future<List<Map<String, dynamic>>> getGiftsForEvent(String eventId) async {
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

  // Add Friend
  Future<int> addFriend(String userId, String friendId) async {
    final db = await database;
    return await db.insert(
      'friends',
      {'user_id': userId, 'friend_id': friendId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicate entries
    );
  }

  // Fetch Friends
  Future<List<String>> getFriends(String userId) async {
    final db = await database;
    final results = await db.query(
      'friends',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty
        ? results.map((row) => row['friend_id'] as String).toList()
        : []; // Return an empty list if no data
  }

  // Gift manipulation functions

  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert(
      'gifts',
      gift,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGift(String id, Map<String, dynamic> gift) async {
    final db = await database;
    return await db.update(
      'gifts',
      gift,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGift(String giftId) async {
    final db = await database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  Future<List<Map<String, dynamic>>> getGiftsPledgedByUser(
      String userId) async {
    final db = await database;
    return await db.query(
      'gifts',
      where: 'pledger_id = ? AND status = ?',
      whereArgs: [userId, 'Pledged'],
    );
  }

  Future<List<Map<String, dynamic>>> getGiftsPledgedToUser(
      String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT g.* 
      FROM gifts g
      JOIN events e ON g.event_id = e.id
      WHERE e.user_id = ? AND g.status = 'Pledged';
    ''', [userId]);
  }

  // Fetch User by Firestore ID (if needed)
  Future<User?> getUserByFirestoreId(String firestoreId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [firestoreId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromSQLite(maps.first);
    } else {
      return null;
    }
  }
}
