// DatabaseHelper.dart
// THIS FILE WILL HOST ANYTHING RELATED TO THE SQLITE IMPLEMENTATION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Event.dart';
import '../models/Gift.dart';
import '../models/LocalUser.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');
    print('Initializing database at: $path');
    return await openDatabase(
      path,
      version: 1, // Incremented version for schema changes
      onConfigure: (db) async {
        // Use rawQuery since PRAGMA returns results.
        await db.rawQuery("PRAGMA journal_mode = DELETE;");
      },
      onCreate: _onCreate,
    );
  }

  /// Creates all required tables during the database initialization.
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        profilePicture TEXT,
        isMe INTEGER,
        notificationPush INTEGER
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        name TEXT,
        date TEXT,
        location TEXT,
        description TEXT,
        category TEXT,
        user_id TEXT,
        is_published INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Gifts table
    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        event_id TEXT,
        pledger_id TEXT,
        is_published INTEGER DEFAULT 1,
        FOREIGN KEY (event_id) REFERENCES events(id),
        FOREIGN KEY (pledger_id) REFERENCES users(id)
      )
    ''');

    // Friends table
    await db.execute('''
      CREATE TABLE friends (
        user_id TEXT,
        friend_id TEXT,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (friend_id) REFERENCES users(id)
      )
    ''');

    print('Database tables created successfully.');
  }

  // insert a user into the local database
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;

    // Check if a user with the same ID already exists
    final existingUser = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [user['id']],
    );

    if (existingUser.isNotEmpty) {
      // Update the existing record
      return await db.update(
        'users',
        user,
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    } else {
      // Insert a new record
      return await db.insert(
        'users',
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Fetch User by ID
  Future<LocalUser?> getUserById(String userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return LocalUser.fromSQLite(maps.first);
    } else {
      return null;
    }
  }

  // Fetch Logged-In User
  Future<LocalUser> getUser() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'isMe = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return LocalUser.fromSQLite(results.first);
    } else {
      throw Exception(
          'No logged-in user found in the database. Please log in again.');
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

  //* Gift manipulation functions

// Insert or replace a gift into the local database
  Future<int> insertGift(Gift gift) async {
    final db = await database;
    return await db.insert(
      'gifts',
      gift.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Update an existing gift
  Future<int> updateGift(String giftId, Map<String, dynamic> giftData) async {
    final db = await database;
    return await db.update(
      'gifts',
      giftData,
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

// Fetch all gifts for a specific event
  Future<List<Gift>> getGiftsForEvent(String eventId) async {
    final db = await database;
    final result = await db.query(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );

    return result.map((row) => Gift.fromMap(row)).toList();
  }

// Delete a specific gift
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
  Future<LocalUser?> getUserByFirestoreId(String firestoreId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [firestoreId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return LocalUser.fromSQLite(maps.first);
    } else {
      return null;
    }
  }

  //* Loading and  publishing from firestore
  // Publish changes from local SQLite to Firebase
  Future<void> publishEventsAndGiftsToFirebase(String userId) async {
    final db = await database;

    // Fetch events from local DB
    final localEvents =
        await db.query('events', where: 'user_id = ?', whereArgs: [userId]);

    for (final event in localEvents) {
      final eventId = event['id'] as String;

      // Publish event to Firebase
      final eventObj = Event.fromSQLite(event);
      await _firebaseHelper.insertEventInFirestore(eventObj);

      // Fetch gifts for the event
      final localGifts =
          await db.query('gifts', where: 'event_id = ?', whereArgs: [eventId]);

      for (final localGift in localGifts) {
        final giftObj = Gift.fromMap(localGift);

        // Fetch the latest gift data from Firestore
        final remoteGift = await _firebaseHelper.getGiftById(giftObj.id);

        // Determine whether to publish the gift
        if (remoteGift != null && remoteGift.status == 'Pledged') {
          // Check if the pledger is someone else
          if (remoteGift.pledgerId != userId) {
            print(
                'Skipping update for gift ${giftObj.id} as it is pledged by another user.');
            continue; // Skip this gift
          }
        }

        // Update Firestore with the local gift (Available or Pledged by the user)
        final updatedGift = giftObj.copyWith(
          pledgerId: giftObj.status == 'Pledged' ? userId : null,
        );

        await _firebaseHelper.insertGiftInFirestore(updatedGift);

        // Mark the gift as published in the local database
        await db.update(
          'gifts',
          {'is_published': 1},
          where: 'id = ?',
          whereArgs: [giftObj.id],
        );
      }
    }
  }

// Synchronize Firebase events and gifts for the current user into SQLite
  Future<void> loadEventsAndGiftsForCurrentUser(String userId) async {
    // Fetch events from Firebase
    final firebaseEvents =
        await _firebaseHelper.getEventsForUserFromFireStore(userId);
    for (final event in firebaseEvents ?? []) {
      await insertEvent(event.toSQLite());
      print(event);

      // Fetch gifts for the event
      final firebaseGifts =
          await _firebaseHelper.getGiftsForEventFromFirestore(event.id);
      for (final gift in firebaseGifts ?? []) {
        await insertGift(gift);
        print(gift);
      }
    }
  }

  void printDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db'); // Replace with your database name
    print('Database Path: $path');
  }
}
