import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/LocalUser.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import '../test_helpers.dart';

import 'firebase_helper_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  DocumentReference,
  QuerySnapshot<Map<String, dynamic>>,
  Query<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
  UserCredential,
  User,
  DocumentSnapshot<Map<String, dynamic>>,
  CollectionReference<Map<String, dynamic>>,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late FirebaseHelper firebaseHelper;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    firebaseHelper = FirebaseHelper(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  tearDown(() {
    reset(mockFirestore);
    clearInteractions(mockFirestore);
  });

  group('User-related Tests', () {
    test('Register User', () async {
      // Stub FirebaseAuth createUserWithEmail
      await stubCreateUserWithEmail(
        mockAuth: mockAuth,
        uid: '123',
        email: 'test@example.com',
        password: 'password123',
      );

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection for 'users'
      when(mockFirestore.collection('users')).thenReturn(mockCollection);

      // Stub Firestore set operation for the new user
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: '123',
        mockDocument: mockDocument,
        setMap: {
          'name': '',
          'email': 'test@example.com',
          'profilePicture': '',
          'isMe': true,
          'notificationPush': true,
        },
        updateMap: {}, // Not used here
      );

      // Call the method under test
      final result =
          await firebaseHelper.registerUser('test@example.com', 'password123');

      // Assertions
      expect(result, isNotNull);
      expect(result?.id, equals('123'));
    });

    test('Login User', () async {
      // Stub FirebaseAuth sign-in
      await stubSignInWithEmail(
        mockAuth: mockAuth,
        uid: '123',
        email: 'test@example.com',
        password: 'password123',
      );

      // Stub FirebaseAuth currentUser getter
      stubFirebaseAuthCurrentUser(
        mockAuth: mockAuth,
        uid: '123',
        email: 'test@example.com',
      );

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection for 'users'
      when(mockFirestore.collection('users')).thenReturn(mockCollection);

      // Stub Firestore document retrieval for the logged-in user
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: '123',
        mockDocument: mockDocument,
        data: {
          'name': 'Test User',
          'email': 'test@example.com',
          'profilePicture': 'path/to/image.png',
          'notificationPush': true,
        },
      );

      // Call the method under test
      final result =
          await firebaseHelper.loginUser('test@example.com', 'password123');

      // Assertions
      expect(result, isNotNull);
      expect(result?.id, equals('123'));
    });

    test('Logout User', () async {
      // Stub FirebaseAuth sign-out
      when(mockAuth.signOut()).thenAnswer((_) async {});

      // Call the method under test
      await firebaseHelper.logoutUser();

      // Verify the sign-out method was called
      verify(mockAuth.signOut()).called(1);
    });

    test('Get Current User', () async {
      // Stub FirebaseAuth currentUser getter
      stubFirebaseAuthCurrentUser(
        mockAuth: mockAuth,
        uid: 'user1',
        email: 'current@example.com',
      );

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection for 'users'
      when(mockFirestore.collection('users')).thenReturn(mockCollection);

      // Stub Firestore document retrieval for the current user
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: 'user1',
        mockDocument: mockDocument,
        data: {
          'name': 'Current User',
          'email': 'current@example.com',
          'profilePicture': 'path/to/image.png',
          'notificationPush': true,
        },
      );

      // Call the method under test
      final result = await firebaseHelper.getCurrentUser();

      // Assertions
      expect(result, isNotNull);
      expect(result?.name, equals('Current User'));
    });

    test('Add Friend in Firestore', () async {
      final userId = 'user1';
      final friendId = 'friend1';
      final updatedFriendData = {
        'friendIds': ['friend2', 'friend1'], // Simulating the added friend
      };

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      print('Stubbing Firestore collection...');
      when(mockFirestore.collection('friends')).thenReturn(mockCollection);

      // Use the helper to stub Firestore document get
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: userId,
        mockDocument: mockDocument,
        data: {
          'friendIds': ['friend2'], // Existing friends before adding
        },
        exists: true, // Ensure the document exists
      );

      // Use the helper to stub Firestore document update
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: userId,
        mockDocument: mockDocument,
        setMap: {}, // Not needed for this test
        updateMap: updatedFriendData, // Updated friend list after adding
      );

      print('Calling addFriendInFirestore...');
      await firebaseHelper.addFriendInFirestore(userId, friendId);

      // Verify the update method was called
      verify(mockDocument.update(updatedFriendData)).called(1);

      print('Test passed!');
    });

    test('Remove Friend in Firestore', () async {
      final userId = 'user1';
      final friendId = 'friend1';
      final updatedFriendData = {
        'friendIds': ['friend2'], // Simulating the removed friend
      };

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      print('Stubbing Firestore collection...');
      when(mockFirestore.collection('friends')).thenReturn(mockCollection);

      // Use the helper to stub Firestore document get
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: userId,
        mockDocument: mockDocument,
        data: {
          'friendIds': [
            'friend2',
            'friend1'
          ], // Existing friends before removing
        },
        exists: true, // Ensure the document exists
      );

      // Use the helper to stub Firestore document update
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: userId,
        mockDocument: mockDocument,
        setMap: {}, // Not needed for this test
        updateMap: updatedFriendData, // Updated friend list after removing
      );

      // Call the method under test
      await firebaseHelper.removeFriendInFirestore(userId, friendId);

      // Verify the update method was called
      verify(mockDocument.update(updatedFriendData)).called(1);

      print('Test passed!');
    });

    test('Search User by Email in Firestore', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      print('Stubbing Firestore collection...');
      when(mockFirestore.collection('users')).thenReturn(mockCollection);

      // Use the helper to stub Firestore query
      await stubFirestoreQuery(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        whereEqualTo: {'email': 'test@example.com'},
        docsData: [
          {
            'id': 'user1', // Stub the document ID
            'name': 'Test User',
            'email': 'test@example.com',
            'profilePicture': 'path/to/image.png',
            'notificationPush': true,
          }
        ],
        mockQuerySnapshot: mockQuerySnapshot,
      );

      // Call the method under test
      final result =
          await firebaseHelper.searchUserByEmailInFirestore('test@example.com');

      // Assertions
      expect(result, isNotNull);
      expect(result?.name, equals('Test User'));
      expect(result?.id, equals('user1')); // Validate the ID as well
    });

    test('Check if User is a Friend', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      print('Stubbing Firestore collection...');
      when(mockFirestore.collection('friends')).thenReturn(mockCollection);

      // Use the helper to stub Firestore document get
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: 'user1',
        mockDocument: mockDocument,
        data: {
          'friendIds': ['friend1', 'friend2'], // Mocked friend IDs
        },
        exists: true, // Ensure the document exists
      );

      // Call the method under test
      final result =
          await firebaseHelper.isFriendInFirestore('user1', 'friend1');

      // Assertions
      expect(result, isTrue);
    });
  });

  group('Event-related Tests', () {
    test('Update Event in Firestore', () async {
      const eventId = 'event1';
      final updatedData = {
        'name': 'Updated Event',
        'location': 'Updated Location',
      };

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('events')).thenReturn(mockCollection);
      when(mockCollection.doc(eventId)).thenReturn(mockDocument);

      // Use the helper to stub Firestore document update
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: eventId,
        mockDocument: mockDocument,
        setMap: {}, // Not needed
        updateMap: updatedData,
      );

      // Call the method under test
      await firebaseHelper.updateEventInFirestore(
        eventId: eventId,
        name: updatedData['name'] as String,
        location: updatedData['location'] as String,
      );

      // Verify the update method was called
      verify(mockDocument.update(updatedData)).called(1);
    });

    test('Get Event by ID', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('events')).thenReturn(mockCollection);
      when(mockCollection.doc('event1')).thenReturn(mockDocument);

      // Use the helper to stub Firestore document get
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: 'event1',
        mockDocument: mockDocument,
        data: {
          'name': 'Test Event',
          'date': '2024-01-01T00:00:00.000',
          'category': 'Birthday',
          'location': 'Home',
          'description': 'A test event',
          'userId': 'user1',
        },
        exists: true,
      );

      // Call the method under test
      final result = await firebaseHelper.getEventById('event1');

      // Assertions
      expect(result, isNotNull);
      expect(result?.name, equals('Test Event'));
    });

    test('Delete Event from Firestore', () async {
      const eventId = 'event1';

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('events')).thenReturn(mockCollection);
      when(mockCollection.doc(eventId)).thenReturn(mockDocument);

      // Stub Firestore document delete
      when(mockDocument.delete()).thenAnswer((_) async {});

      // Call the method under test
      await firebaseHelper.deleteEventInFirestore(eventId);

      // Verify the delete method was called
      verify(mockDocument.delete()).called(1);
    });

    test('Insert Event into Firestore', () async {
      final testEvent = Event(
        id: 'event1',
        name: 'Test Event',
        date: DateTime(2024, 1, 1),
        category: 'Birthday',
        location: 'Home',
        description: 'Test Description',
        userId: '123',
        isPublished: true,
      );

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('events')).thenReturn(mockCollection);
      when(mockCollection.doc(testEvent.id)).thenReturn(mockDocument);

      // Use the helper to stub Firestore document set
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: testEvent.id,
        mockDocument: mockDocument,
        setMap: testEvent.toFirestore(),
        updateMap: {}, // Not needed
      );

      // Call the method under test
      await firebaseHelper.insertEventInFirestore(testEvent);

      // Verify the set method was called
      verify(mockDocument.set(testEvent.toFirestore())).called(1);
    });

    test('Get Events for User from Firestore', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      // Stub Firestore collection
      when(mockFirestore.collection('events')).thenReturn(mockCollection);

      // Use the helper to stub Firestore query
      await stubFirestoreQuery(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        whereEqualTo: {'userId': 'user1'},
        docsData: [
          {
            'id': 'event1',
            'name': 'Test Event',
            'date': '2024-01-01T00:00:00.000',
            'category': 'Birthday',
            'location': 'Home',
            'description': 'A test event',
            'userId': 'user1',
          }
        ],
        mockQuerySnapshot: mockQuerySnapshot,
      );

      // Call the method under test
      final result =
          await firebaseHelper.getEventsForUserFromFireStore('user1');

      // Assertions
      expect(result, isNotNull);
      expect(result?.length, equals(1));
      expect(result?.first.name, equals('Test Event'));
    });
  });

  group('Gift-related Tests', () {
    test('Get Gifts for Event from Firestore', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      // Stub Firestore collection
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);

      // Use the helper to stub Firestore query
      await stubFirestoreQuery(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        whereEqualTo: {'event_id': 'event1'},
        docsData: [
          {
            'id': 'gift1',
            'name': 'Test Gift',
            'description': 'A gift for the event',
            'category': 'Electronics',
            'price': 50.0,
            'status': 'Available',
            'event_id': 'event1',
          }
        ],
        mockQuerySnapshot: mockQuerySnapshot,
      );

      // Call the method under test
      final result =
          await firebaseHelper.getGiftsForEventFromFirestore('event1');

      // Assertions
      expect(result, isNotNull);
      expect(result?.length, equals(1));
      expect(result?.first.name, equals('Test Gift'));
    });

    test('Delete Gift from Firestore', () async {
      const giftId = 'gift1';

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);
      when(mockCollection.doc(giftId)).thenReturn(mockDocument);

      // Stub Firestore document delete
      when(mockDocument.delete()).thenAnswer((_) async {});

      // Call the method under test
      await firebaseHelper.deleteGiftInFirestore(giftId);

      // Verify the delete method was called
      verify(mockDocument.delete()).called(1);
    });

    test('Get Pledged Gifts from User from Firestore', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      // Stub Firestore collection
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);

      // Use the helper to stub Firestore query
      await stubFirestoreQuery(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        whereEqualTo: {'pledger_id': 'user1'},
        docsData: [
          {
            'id': 'gift 1',
            'name': 'Test Gift',
            'description': 'A pledged gift',
            'category': 'Electronics',
            'price': 50.0,
            'status': 'Pledged',
            'event_id': 'event1',
            'pledger_id': 'user1',
          }
        ],
        mockQuerySnapshot: mockQuerySnapshot,
      );

      // Call the method under test
      final result =
          await firebaseHelper.getPledgedGiftsFromUserFromFirestore('user1');

      // Assertions
      expect(result, isNotNull);
      expect(result?.length, equals(1));
      expect(result?.first.name, equals('Test Gift'));
    });

    test('Get Gift by ID', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);
      when(mockCollection.doc('gift1')).thenReturn(mockDocument);

      // Use the helper to stub Firestore document get
      await stubFirestoreDocGet(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: 'gift1',
        mockDocument: mockDocument,
        data: {
          'name': 'Test Gift',
          'description': 'Test Description',
          'category': 'Electronics',
          'price': 50.0,
          'status': 'Available',
          'event_id': 'event1',
          'pledger_id': null,
        },
        exists: true,
      );

      // Call the method under test
      final result = await firebaseHelper.getGiftById('gift1');

      // Assertions
      expect(result, isNotNull);
      expect(result?.name, equals('Test Gift'));
    });

    test('Insert Gift into Firestore', () async {
      final testGift = Gift(
        id: 'gift1',
        name: 'Test Gift',
        description: 'A test gift',
        category: 'Electronics',
        price: 50.0,
        status: 'Available',
        eventId: 'event1',
        pledgerId: null,
        isPublished: true,
      );

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);
      when(mockCollection.doc(testGift.id)).thenReturn(mockDocument);

      // Use the helper to stub Firestore document set
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: testGift.id,
        mockDocument: mockDocument,
        setMap: testGift.toFirestore(),
        updateMap: {}, // Not needed here
      );

      // Call the method under test
      await firebaseHelper.insertGiftInFirestore(testGift);

      // Verify the set method was called
      verify(mockDocument.set(testGift.toFirestore())).called(1);
    });

    test('Update Gift in Firestore', () async {
      const giftId = 'gift1';
      final updatedData = {
        'name': 'Updated Gift',
        'price': 100.0,
        'status': 'Pledged',
        'pledger_id': 'user1', // can be null also and will still work
      };

      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Stub Firestore collection and document
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);
      when(mockCollection.doc(giftId)).thenReturn(mockDocument);

      // Use the helper to stub Firestore document update
      stubFirestoreDocWrite(
        mockFirestore: mockFirestore,
        mockCollection: mockCollection,
        docId: giftId,
        mockDocument: mockDocument,
        setMap: {}, // Not needed
        updateMap: updatedData,
      );

      // Call the method under test
      await firebaseHelper.updateGiftInFirestore(
        giftId: giftId,
        name: updatedData['name'] as String,
        price: updatedData['price'] as double,
        status: updatedData['status'] as String,
        pledgerId: updatedData['pledger_id'] as String?,
      );

      // Verify the update method was called
      verify(mockDocument.update(updatedData)).called(1);
    });
  });

  group('Notifications-related Tests', () {
    test('Listen for Pledged Gifts', () async {
      // Create shared mock references
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockStream = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();

      print('Stubbing Firestore collection...');
      when(mockFirestore.collection('gifts')).thenReturn(mockCollection);

      // Stub Firestore query and snapshots stream
      when(mockCollection.where('status', isEqualTo: 'Pledged'))
          .thenReturn(mockCollection);
      when(mockCollection.snapshots()).thenAnswer((_) {
        print(
            'MockCollection.snapshots() called for gifts with status Pledged');
        return mockStream;
      });

      // Call the method under test
      firebaseHelper.listenForPledgedGifts('user1');

      // Verify that snapshots stream was accessed
      verify(mockCollection.where('status', isEqualTo: 'Pledged')).called(1);
      verify(mockCollection.snapshots()).called(1);
    });
  });
}
