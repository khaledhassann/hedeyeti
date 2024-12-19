// test/test_helpers.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/firebase_helper_test.mocks.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/LocalUser.dart';

/// Creates a mock DocumentSnapshot with given data and existence state.
DocumentSnapshot<Map<String, dynamic>> createMockDocSnapshot({
  bool exists = true,
  Map<String, dynamic>? data,
}) {
  final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();
  when(mockDoc.exists).thenReturn(exists);
  when(mockDoc.data()).thenReturn(data);
  return mockDoc;
}

/// Creates a mock QuerySnapshot with the provided list of document data.
QuerySnapshot<Map<String, dynamic>> createMockQuerySnapshot(
  List<Map<String, dynamic>> docsData,
) {
  final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockDocs = docsData.map((data) {
    final doc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(doc.data()).thenReturn(data);
    return doc;
  }).toList();

  when(mockQuerySnapshot.docs).thenReturn(mockDocs);
  return mockQuerySnapshot;
}

/// Creates a mock User with specified UID and optional email.
User createMockUser({required String uid, String? email}) {
  final mockUser = MockUser();
  when(mockUser.uid).thenReturn(uid);
  if (email != null) {
    when(mockUser.email).thenReturn(email);
  }
  return mockUser;
}

/// Creates a mock UserCredential with a given mocked User.
UserCredential createMockUserCredential({required User user}) {
  final mockUserCredential = MockUserCredential();
  when(mockUserCredential.user).thenReturn(user);
  return mockUserCredential;
}

/// Stubs FirebaseAuth sign-in with given UID (and optional email/password).
Future<void> stubSignInWithEmail({
  required FirebaseAuth mockAuth,
  required String uid,
  String email = 'test@example.com',
  String password = 'password123',
}) async {
  final user = createMockUser(uid: uid, email: email);
  final userCredential = createMockUserCredential(user: user);

  when(mockAuth.signInWithEmailAndPassword(email: email, password: password))
      .thenAnswer((_) async => userCredential);
}

/// Stubs FirebaseAuth create user with given UID (and optional email/password).
Future<void> stubCreateUserWithEmail({
  required FirebaseAuth mockAuth,
  required String uid,
  String email = 'test@example.com',
  String password = 'password123',
}) async {
  final user = createMockUser(uid: uid, email: email);
  final userCredential = createMockUserCredential(user: user);

  when(mockAuth.createUserWithEmailAndPassword(
          email: email, password: password))
      .thenAnswer((_) async => userCredential);
}

/// Stubs FirebaseAuth's currentUser getter to return a mock user.
void stubFirebaseAuthCurrentUser({
  required FirebaseAuth mockAuth,
  required String uid,
  String? email,
}) {
  final mockUser = createMockUser(uid: uid, email: email);
  when(mockAuth.currentUser).thenReturn(mockUser);
}

/// Stubs a Firestore document get operation to return a document with given data.
Future<void> stubFirestoreDocGet({
  required FirebaseFirestore mockFirestore,
  required MockCollectionReference<Map<String, dynamic>> mockCollection,
  required String docId,
  required MockDocumentReference<Map<String, dynamic>> mockDocument,
  Map<String, dynamic>? data,
  bool exists = true,
}) async {
  print('Stubbing Firestore collection, doc: $docId');

  final mockSnapshot = createMockDocSnapshot(data: data, exists: exists);

  // Stub the id property of the mock snapshot
  when(mockSnapshot.id).thenReturn(docId);

  // Stub the document call
  when(mockCollection.doc(docId)).thenReturn(mockDocument);

  // Stub the get() method on the document reference
  when(mockDocument.get()).thenAnswer((_) async {
    print('MockDocument.get() called for friends/$docId');
    return mockSnapshot;
  });
  // Support the `[]` operator if data is provided
  if (data != null) {
    data.forEach((key, value) {
      when(mockSnapshot[key]).thenReturn(value);
    });
  }
}

/// Stubs Firestore document writes (set/update) to simply succeed.
void stubFirestoreDocWrite({
  required FirebaseFirestore mockFirestore,
  required MockCollectionReference<Map<String, dynamic>> mockCollection,
  required String docId,
  required MockDocumentReference<Map<String, dynamic>> mockDocument,
  required Map<String, dynamic> setMap,
  required Map<String, dynamic> updateMap,
}) {
  print('Stubbing Firestore collection, doc: $docId');

  // Stub the document call
  when(mockCollection.doc(docId)).thenReturn(mockDocument);

  // Stub the set operation and log its invocation
  when(mockDocument.set(setMap)).thenAnswer((_) async {
    print('MockDocument.set() called with: $setMap');
  });

  // Stub the update operation and log its invocation
  when(mockDocument.update(updateMap)).thenAnswer((_) async {
    print('MockDocument.update() called with: $updateMap');
  });
}

/// Stubs Firestore document delete to succeed.
void stubFirestoreDocDelete({
  required FirebaseFirestore mockFirestore,
  required String collectionPath,
  required String docId,
}) {
  when(mockFirestore.collection(collectionPath).doc(docId).delete())
      .thenAnswer((_) async {});
}

/// Stubs a Firestore query to return multiple documents.
/// You can enhance this function to handle multiple where clauses if needed.
/// Stubs a Firestore query to return multiple documents.
Future<void> stubFirestoreQuery({
  required FirebaseFirestore mockFirestore,
  required MockCollectionReference<Map<String, dynamic>> mockCollection,
  required Map<String, dynamic>? whereEqualTo,
  required List<Map<String, dynamic>> docsData,
  required MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot,
}) async {
  print('Stubbing Firestore query...');

  // Stub the where clause
  if (whereEqualTo != null) {
    whereEqualTo.forEach((key, value) {
      when(mockCollection.where(key, isEqualTo: value))
          .thenReturn(mockCollection);
    });
  }

  // Stub the get() method to return the mockQuerySnapshot
  when(mockCollection.get()).thenAnswer((_) async {
    print('MockCollection.get() called for query');
    return mockQuerySnapshot;
  });

  // Stub the docs in the query snapshot
  final mockDocs = docsData.map((docData) {
    final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(mockDoc.id).thenReturn(docData['id'] as String);
    when(mockDoc.data()).thenReturn(docData..remove('id'));
    return mockDoc;
  }).toList();

  when(mockQuerySnapshot.docs).thenReturn(mockDocs);
}

/// Creates a sample Event object for testing.
Event createTestEvent({
  String id = 'event1',
  String name = 'Test Event',
  DateTime? date,
  String category = 'Birthday',
  String location = 'Home',
  String description = 'A test event',
  String userId = 'user1',
  bool isPublished = true,
}) {
  return Event(
    id: id,
    name: name,
    date: date ?? DateTime(2024, 1, 1),
    category: category,
    location: location,
    description: description,
    userId: userId,
    isPublished: isPublished,
  );
}

/// Creates a sample Gift object for testing.
Gift createTestGift({
  String id = 'gift1',
  String name = 'Test Gift',
  String description = 'A test gift',
  String category = 'Electronics',
  double price = 50.0,
  String status = 'Available',
  String eventId = 'event1',
  String? pledgerId,
  bool isPublished = true,
}) {
  return Gift(
    id: id,
    name: name,
    description: description,
    category: category,
    price: price,
    status: status,
    eventId: eventId,
    pledgerId: pledgerId,
    isPublished: isPublished,
  );
}

/// Creates a sample LocalUser object for testing.
LocalUser createTestLocalUser({
  String id = 'user1',
  String name = 'Test User',
  String email = 'test@example.com',
  String profilePicture = 'path/to/image.png',
  bool notificationPush = true,
  bool isMe = true,
}) {
  return LocalUser(
    id: id,
    name: name,
    email: email,
    profilePicture: profilePicture,
    notificationPush: notificationPush,
    isMe: true,
  );
}
