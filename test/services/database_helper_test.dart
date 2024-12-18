import 'package:flutter_test/flutter_test.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hedeyeti/services/database_helper.dart';
import 'package:hedeyeti/models/LocalUser.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';

import 'database_helper_test.mocks.dart';

@GenerateMocks([FirebaseHelper])
void main() {
  late DatabaseHelper databaseHelper;
  late MockFirebaseHelper mockFirebaseHelper;

  setUpAll(() {
    // Initialize sqflite_common_ffi for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockFirebaseHelper = MockFirebaseHelper();
    databaseHelper = DatabaseHelper(firebaseHelper: mockFirebaseHelper);
    databaseHelper = DatabaseHelper(firebaseHelper: mockFirebaseHelper);
    final db = await databaseHelper.database;
    await db.delete('events'); // Clear events table before each test
    await db.delete('gifts');
  });

  group('DatabaseHelper Unit Tests', () {
    //* User related tests
    test('Insert User into SQLite', () async {
      final testUser = LocalUser(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        profilePicture: 'path/to/image.png',
        isMe: true,
        notificationPush: true,
      );

      final result = await databaseHelper.insertUser(testUser.toSQLite());

      expect(result, isNonZero); // Ensure the insert returns a valid row ID
    });

    test('Fetch User by ID', () async {
      final testUser = LocalUser(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        profilePicture: 'path/to/image.png',
        isMe: true,
        notificationPush: true,
      );

      await databaseHelper.insertUser(testUser.toSQLite());
      final fetchedUser = await databaseHelper.getUserById(testUser.id);

      expect(fetchedUser?.id, equals(testUser.id));
      expect(fetchedUser?.name, equals(testUser.name));
    });

    test('Fetch Logged-In User', () async {
      final loggedInUser = LocalUser(
        id: '1',
        name: 'Logged-In User',
        email: 'loggedin@example.com',
        profilePicture: 'path/to/image.png',
        isMe: true,
        notificationPush: true,
      );

      await databaseHelper.insertUser(loggedInUser.toSQLite());
      final fetchedUser = await databaseHelper.getUser();

      expect(fetchedUser.id, equals(loggedInUser.id));
      expect(fetchedUser.name, equals(loggedInUser.name));
    });

    //* Event related tests
    test('Insert Event into SQLite', () async {
      final testEvent = Event(
        id: 'event1',
        name: 'Test Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'A test event',
        userId: '123',
        isPublished: true,
      );

      final result = await databaseHelper.insertEvent(testEvent.toSQLite());

      expect(result, isNonZero); // Ensure the insert returns a valid row ID
    });

    test('Update Event', () async {
      final testEvent = Event(
        id: 'event1',
        name: 'Old Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'Old Description',
        userId: '123',
        isPublished: true,
      );

      await databaseHelper.insertEvent(testEvent.toSQLite());

      final updatedEvent = testEvent.copyWith(name: 'Updated Event');
      final result = await databaseHelper.updateEvent(
          updatedEvent.id, updatedEvent.toSQLite());

      expect(result, equals(1));
      final fetchedEvents =
          await databaseHelper.getEventsForUser(testEvent.userId);
      expect(fetchedEvents.first['name'], equals('Updated Event'));
    });

    test('Fetch Events for User', () async {
      const userId = '123';

      final testEvent = Event(
        id: '1',
        name: 'Test Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'A test event',
        userId: userId,
        isPublished: true,
      );

      await databaseHelper.insertEvent(testEvent.toSQLite());

      final results = await databaseHelper.getEventsForUser(userId);

      expect(results.length, equals(1));
      expect(results.first['name'], equals('Test Event'));
    });

    test('Delete Event', () async {
      final testEvent = Event(
        id: 'event123',
        name: 'Event to Delete',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'A test event',
        userId: '123',
        isPublished: true,
      );

      await databaseHelper.insertEvent(testEvent.toSQLite());
      final result = await databaseHelper.deleteEvent(testEvent.id);

      expect(result, equals(1)); // Expect one row to be deleted
    });
    //* Gift related tests
    test('Insert Gift into SQLite', () async {
      final testGift = Gift(
        id: 'gift1',
        name: 'Test Gift',
        description: 'A test gift',
        category: 'Electronics',
        price: 100.0,
        status: 'Available',
        eventId: 'event1',
        pledgerId: null,
        isPublished: true,
      );

      final result = await databaseHelper.insertGift(testGift);

      expect(result, isNonZero); // Ensure the insert returns a valid row ID
    });
    test('Fetch Gifts for Event', () async {
      const eventId = 'event1';
      final testGift = Gift(
        id: 'gift1',
        name: 'Test Gift',
        description: 'A test gift',
        category: 'Electronics',
        price: 100.0,
        status: 'Available',
        eventId: eventId,
        pledgerId: null,
        isPublished: true,
      );

      await databaseHelper.insertGift(testGift);
      final fetchedGifts = await databaseHelper.getGiftsForEvent(eventId);

      expect(fetchedGifts.length, equals(1));
      expect(fetchedGifts.first.name, equals(testGift.name));
    });

    test('Update Gift', () async {
      final testGift = Gift(
        id: 'gift1',
        name: 'Old Gift',
        description: 'Old Description',
        category: 'Electronics',
        price: 50.0,
        status: 'Available',
        eventId: 'event1',
        pledgerId: null,
        isPublished: true,
      );

      await databaseHelper.insertGift(testGift);

      final updatedGift = testGift.copyWith(name: 'Updated Gift');
      final result =
          await databaseHelper.updateGift(updatedGift.id, updatedGift.toMap());

      expect(result, equals(1));
      final fetchedGifts =
          await databaseHelper.getGiftsForEvent(testGift.eventId);
      expect(fetchedGifts.first.name, equals('Updated Gift'));
    });

    test('Fetch Gifts Pledged by User', () async {
      const userId = 'user1';
      final testGift = Gift(
        id: 'gift1',
        name: 'Pledged Gift',
        description: 'A pledged gift',
        category: 'Electronics',
        price: 100.0,
        status: 'Pledged',
        eventId: 'event1',
        pledgerId: userId,
        isPublished: true,
      );

      await databaseHelper.insertGift(testGift);
      final pledgedGifts = await databaseHelper.getGiftsPledgedByUser(userId);

      expect(pledgedGifts.length, equals(1));
      expect(pledgedGifts.first['id'], equals(testGift.id));
    });

    test('Fetch Gifts Pledged to User', () async {
      const userId = 'user1';
      final testEvent = Event(
        id: 'event1',
        name: 'Test Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'A test event',
        userId: userId,
        isPublished: true,
      );

      final testGift = Gift(
        id: 'gift1',
        name: 'Gift Pledged to User',
        description: 'A gift pledged to the user',
        category: 'Electronics',
        price: 100.0,
        status: 'Pledged',
        eventId: 'event1',
        pledgerId: 'pledger1',
        isPublished: true,
      );

      await databaseHelper.insertEvent(testEvent.toSQLite());
      await databaseHelper.insertGift(testGift);

      final pledgedGifts = await databaseHelper.getGiftsPledgedToUser(userId);

      expect(pledgedGifts.length, equals(1));
      expect(pledgedGifts.first['id'], equals(testGift.id));
    });

    //* Friends related tests
    test('Add Friend', () async {
      const userId = 'user1';
      const friendId = 'friend1';

      final result = await databaseHelper.addFriend(userId, friendId);

      expect(result, equals(1));
      final friends = await databaseHelper.getFriends(userId);
      expect(friends, contains(friendId));
    });

    test('Remove Friend', () async {
      const userId = 'user1';
      const friendId = 'friend1';

      await databaseHelper.addFriend(userId, friendId);
      final result = await databaseHelper.removeFriend(userId, friendId);

      expect(result, equals(1));
      final friends = await databaseHelper.getFriends(userId);
      expect(friends, isEmpty);
    });
  });

  group('DatabaseHelper Integration Tests', () {
    test('Publish Events and Gifts to Firebase', () async {
      const userId = '123';
      final testEvent = Event(
        id: 'event1',
        name: 'Test Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'Test Description',
        userId: userId,
        isPublished: false,
      );

      final testGift = Gift(
        id: 'gift1',
        name: 'Test Gift',
        description: 'Test Gift Description',
        category: 'Electronics',
        price: 99.99,
        status: 'Available',
        eventId: 'event1',
        pledgerId: null,
        isPublished: false,
      );

      await databaseHelper.insertEvent(testEvent.toSQLite());
      await databaseHelper.insertGift(testGift);

      // Mock getGiftById to return null (or a mock gift)
      when(mockFirebaseHelper.getGiftById(testGift.id))
          .thenAnswer((_) async => null);

      when(mockFirebaseHelper.insertEventInFirestore(any))
          .thenAnswer((_) async {});
      when(mockFirebaseHelper.insertGiftInFirestore(any))
          .thenAnswer((_) async {});

      await databaseHelper.publishEventsAndGiftsToFirebase(userId);

      verify(mockFirebaseHelper.insertEventInFirestore(any)).called(1);
      verify(mockFirebaseHelper.insertGiftInFirestore(any)).called(1);
    });
    test('Load Events and Gifts from Firebase', () async {
      const userId = '123';

      when(mockFirebaseHelper.getEventsForUserFromFireStore(userId))
          .thenAnswer((_) async => [
                Event(
                  id: 'event1',
                  name: 'Test Event',
                  date: DateTime(2024, 1, 1),
                  category: 'Birthday',
                  location: 'Home',
                  description: 'Test Description',
                  userId: userId,
                  isPublished: true,
                )
              ]);

      when(mockFirebaseHelper.getGiftsForEventFromFirestore('event1'))
          .thenAnswer((_) async => [
                Gift(
                  id: 'gift1',
                  name: 'Test Gift',
                  description: 'A test gift',
                  category: 'Electronics',
                  price: 50.0,
                  status: 'Available',
                  eventId: 'event1',
                  pledgerId: null,
                  isPublished: true,
                )
              ]);

      await databaseHelper.loadEventsAndGiftsForCurrentUser(userId);

      final events = await databaseHelper.getEventsForUser(userId);
      expect(events.length, equals(1));
      expect(events.first['name'], equals('Test Event'));

      final gifts = await databaseHelper.getGiftsForEvent('event1');
      expect(gifts.length, equals(1));
      expect(gifts.first.name, equals('Test Gift'));
    });
  });
}
