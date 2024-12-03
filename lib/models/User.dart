// User.dart
import 'package:hedeyeti/models/Event.dart';

class User {
  final String id; // Unified ID as a String (Firestore ID)
  final String name;
  final String email;
  final String profilePicture;
  final bool isMe;
  final List<Event> events;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.isMe,
    required this.events,
  });

  // Parse from SQLite map
  factory User.fromSQLite(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String, // Now a String
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      profilePicture: map['profilePicture'] ?? 'assets/default-avatar.png',
      isMe: map['isMe'] == 1, // SQLite stores booleans as integers
      events: [], // Populate from SQLite or Firestore later
    );
  }

  // Parse from Firestore document
  factory User.fromFirestore(Map<String, dynamic> map, String id) {
    return User(
      id: id, // Directly use Firestore ID as String
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      profilePicture: map['profilePicture'] ?? 'assets/default-avatar.png',
      isMe: false, // Firestore users are friends, not the logged-in user
      events: [], // Populate events separately
    );
  }

  // Convert to SQLite map
  Map<String, dynamic> toSQLite() {
    return {
      'id': id, // Now a String
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'isMe': isMe ? 1 : 0, // Store booleans as integers
    };
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}
