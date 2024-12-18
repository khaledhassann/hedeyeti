// firebase_helper.dart
// THIS FILE WILL HOST ANYTHING THAT GETS DATA FROM FIREBASE/FIRESTORE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/LocalUser.dart';

import 'notification_helper.dart';

class FirebaseHelper {
  // Step 1: Create a private static instance of the class
  static final FirebaseHelper _instance = FirebaseHelper._internal();

  // Step 2: Factory constructor to return the single instance
  factory FirebaseHelper({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    _instance._firestore = firestore ?? FirebaseFirestore.instance;
    _instance._auth = auth ?? FirebaseAuth.instance;
    return _instance;
  }

  // Firestore instance
  late FirebaseFirestore _firestore;
  late auth.FirebaseAuth _auth;

  // Step 3: Private constructor to prevent external instantiation
  FirebaseHelper._internal();

  // Step 4: Define Firestore collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get events => _firestore.collection('events');
  CollectionReference get gifts => _firestore.collection('gifts');
  CollectionReference get friends => _firestore.collection('friends');

  // Authentication functions

  // Register a new user with email and password
  Future<LocalUser?> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Create user document in Firestore
        final user = LocalUser(
          id: firebaseUser.uid,
          name: '',
          email: email,
          profilePicture: '',
          isMe: true,
          notificationPush: true,
        );
        await users.doc(firebaseUser.uid).set(user.toFirestore());
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Login a user with email and password
  Future<LocalUser?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return await getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Error logging in user: $e');
      rethrow;
    }
  }

  // Logout the current user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out user: $e');
    }
  }

  // Fetch the currently logged-in user's data from Firestore
  Future<LocalUser?> getCurrentUser() async {
    try {
      final currentUser =
          _auth.currentUser; // Get the currently logged-in Firebase user
      if (currentUser != null) {
        final userDoc =
            await users.doc(currentUser.uid).get(); // Fetch Firestore document
        if (userDoc.exists) {
          return LocalUser.fromFirestoreLoggedInUser(
              userDoc.data() as Map<String, dynamic>,
              userDoc.id); // Parse user data
        }
      }
      return null; // Return null if no user is logged in or document doesn't exist
    } catch (e) {
      print('Error getting current user: $e');
      return null; // Return null on error
    }
  }

  //* LocalUser direct functions

  // Fetch a user document from Firestore by userId
  Future<LocalUser?> getUserFromFirestore(String userId) async {
    try {
      final doc = await users.doc(userId).get(); // Fetch document
      if (doc.exists) {
        return LocalUser.fromFirestore(doc.data() as Map<String, dynamic>,
            doc.id); // Parse user data using User model
      }
      return null; // Return null if user doesn't exist
    } catch (e) {
      print('Error getting user: $e');
      return null; // Return null on error
    }
  }

  // Update a user document with optional parameters
  Future<void> updateUserInFirestore({
    required String userId,
    String? name,
    String? email,
    String? profilePicture,
    bool? notificationPush,
  }) async {
    try {
      final data = <String, dynamic>{}; // Initialize update map
      if (name != null) data['name'] = name; // Add name if provided
      if (email != null) data['email'] = email; // Add email if provided
      if (notificationPush != null) data['notificationPush'] = notificationPush;
      if (profilePicture != null)
        data['profilePicture'] =
            profilePicture; // Add profile picture if provided
      await users.doc(userId).update(data); // Update Firestore document
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Add a friend to the user's friend list in Firestore
  Future<void> addFriendInFirestore(String userId, String friendId) async {
    try {
      final doc = await friends.doc(userId).get(); // Fetch friend's document
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final friendIds =
            List<String>.from(data['friendIds'] ?? []); // Parse friend IDs
        if (!friendIds.contains(friendId)) {
          friendIds.add(friendId); // Add new friend if not already added
          await friends
              .doc(userId)
              .update({'friendIds': friendIds}); // Update Firestore
        }
      } else {
        await friends.doc(userId).set({
          'friendIds': [friendId]
        }); // Create new friend list
      }
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

// Remove a friend from the user's friend list in Firestore
  Future<void> removeFriendInFirestore(String userId, String friendId) async {
    try {
      final doc =
          await friends.doc(userId).get(); // Fetch user's friends document
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final friendIds =
            List<String>.from(data['friendIds'] ?? []); // Parse friend IDs
        if (friendIds.contains(friendId)) {
          friendIds.remove(friendId); // Remove the friend ID
          await friends
              .doc(userId)
              .update({'friendIds': friendIds}); // Update Firestore
        }
      }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  // Search user by email
  Future<LocalUser?> searchUserByEmailInFirestore(String email) async {
    try {
      final querySnapshot = await users.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isEmpty) return null;

      final userDoc = querySnapshot.docs.first;
      return LocalUser.fromFirestore(
          userDoc.data() as Map<String, dynamic>, userDoc.id);
    } catch (e) {
      print('Error searching user by email: $e');
      return null;
    }
  }

  // Check if a user is a friend
  Future<bool> isFriendInFirestore(String userId, String friendId) async {
    try {
      final friendDoc = await friends.doc(userId).get();
      if (!friendDoc.exists) return false;

      final friendList = List<String>.from(friendDoc['friendIds'] ?? []);
      return friendList.contains(friendId);
    } catch (e) {
      print('Error checking if user is a friend: $e');
      return false;
    }
  }

  // Fetch friends of a user and return a list of User objects
  Future<List<LocalUser>> getFriendsFromFirestore(String userId) async {
    try {
      final doc = await friends.doc(userId).get(); // Fetch friend's document
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final friendIds =
            List<String>.from(data['friendIds'] ?? []); // Parse friend IDs
        final localListOfFriends = <LocalUser>[];
        for (final friendId in friendIds) {
          final friend =
              await getUserFromFirestore(friendId); // Fetch each friend
          if (friend != null) {
            localListOfFriends.add(friend); // Add to the list if found
          }
        }
        return localListOfFriends; // Return list of friends
      }
      return []; // Return empty list if no friends
    } catch (e) {
      print('Error getting friends: $e');
      return []; // Return null on error
    }
  }

  //* Event direct functions

  // Add a new event to Firestore
  Future<void> insertEventInFirestore(Event event) async {
    try {
      await events
          .doc(event.id)
          .set(event.toFirestore()); // Use Event's toFirestore method
    } catch (e) {
      print('Error inserting event: $e');
    }
  }

  // Update an event with optional parameters
  Future<void> updateEventInFirestore({
    required String eventId,
    String? name,
    DateTime? date,
    String? category,
    String? location,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{}; // Initialize update map
      if (name != null) data['name'] = name; // Add name if provided
      if (date != null)
        data['date'] = date.toIso8601String(); // Add date if provided
      if (category != null)
        data['category'] = category; // Add category if provided
      if (location != null)
        data['location'] = location; // Add location if provided
      if (description != null)
        data['description'] = description; // Add description if provided
      await events.doc(eventId).update(data); // Update Firestore document
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  // Delete an event from Firestore
  Future<void> deleteEventInFirestore(String eventId) async {
    try {
      await events.doc(eventId).delete(); // Delete event document
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // Fetch events for a user from Firestore
  Future<List<Event>>? getEventsForUserFromFireStore(String userId) async {
    try {
      final querySnapshot = await events
          .where('userId', isEqualTo: userId)
          .get(); // Query events by userId
      return querySnapshot.docs
          .map((doc) =>
              Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(); // Parse and return event list
    } catch (e) {
      print('Error getting events: $e');
      return []; // Return null on error
    }
  }

  // Fetch an event by it's ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await events.doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching event by ID: $e');
      return null;
    }
  }

  //* Gift direct functions

  // Fetch an event by it's ID
  Future<Gift?> getGiftById(String giftId) async {
    try {
      final doc = await gifts.doc(giftId).get();
      if (doc.exists) {
        return Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching gift by ID: $e');
      return null;
    }
  }

  // Fetch gifts for a specific event
  Future<List<Gift>?> getGiftsForEventFromFirestore(String eventId) async {
    try {
      final querySnapshot = await gifts
          .where('event_id', isEqualTo: eventId)
          .get(); // Query gifts by eventId
      return querySnapshot.docs
          .map((doc) =>
              Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(); // Parse and return gift list
    } catch (e) {
      print('Error getting gifts for event: $e');
      return null; // Return null on error
    }
  }

  // Fetch pledged gifts by a user
  Future<List<Gift>?> getPledgedGiftsFromUserFromFirestore(
      String userId) async {
    try {
      final querySnapshot = await gifts
          .where('pledger_id', isEqualTo: userId)
          .get(); // Query gifts by pledgerId
      return querySnapshot.docs
          .map((doc) =>
              Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(); // Parse and return gift list
    } catch (e) {
      print('Error getting pledged gifts: $e');
      return null; // Return null on error
    }
  }

  // Insert a new gift into Firestore
  Future<void> insertGiftInFirestore(Gift gift) async {
    try {
      await gifts
          .doc(gift.id)
          .set(gift.toFirestore()); // Use Gift's toFirestore method
    } catch (e) {
      print('Error inserting gift: $e');
    }
  }

  // Update a gift with optional parameters
  Future<void> updateGiftInFirestore({
    required String giftId,
    String? name,
    String? category,
    String? description,
    double? price,
    String? status,
    String? pledgerId,
  }) async {
    try {
      final data = <String, dynamic>{}; // Initialize update map
      if (name != null) data['name'] = name; // Add name if provided
      if (category != null) {
        data['category'] = category; // Add category if provided
      }
      if (description != null) {
        data['description'] = description; // Add description if provided
      }
      if (price != null) data['price'] = price; // Add price if provided
      if (status != null) data['status'] = status; // Add status if provided
      data['pledger_id'] = pledgerId;
      await gifts.doc(giftId).update(data); // Update Firestore document
    } catch (e) {
      print('Error updating gift: $e');
    }
  }

  // Delete a gift from Firestore
  Future<void> deleteGiftInFirestore(String giftId) async {
    try {
      await gifts.doc(giftId).delete(); // Delete gift document
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }

  void listenForPledgedGifts(String userId) {
    gifts
        .where('status', isEqualTo: 'Pledged')
        .snapshots()
        .listen((snapshot) async {
      final events = await getEventsForUserFromFireStore(userId);
      final eventIds = events?.map((event) => event.id).toSet() ?? {};

      // Fetch the user's notificationPush preference
      final currentUser = await getCurrentUser();
      final userNotificationPush = currentUser!.notificationPush;

      if (!userNotificationPush) {
        print('Push notifications are disabled for this user.');
        return; // Skip notifications if disabled
      }

      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data() as Map<String, dynamic>;
          final eventId = data['event_id'] as String;
          print('Listening for pledged gifts...');
          print('Gift pledged: $data');

          // Check if the gift belongs to the user's events
          if (eventIds.contains(eventId)) {
            // Show the notification using the helper
            await NotificationHelper.showGiftNotification(data);
          }
        }
      }
    });
  }
}
