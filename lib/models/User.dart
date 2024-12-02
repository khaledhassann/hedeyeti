import 'Event.dart';

class User {
  int? id; // Primary key for SQLite
  String name;
  String email;
  String profilePicture;
  bool isMe;
  List<Event> events;

  User({
    this.id, // Nullable for new users
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.isMe,
    required this.events,
  });

  // Convert User to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'is_me': isMe ? 1 : 0, // Store as integer (SQLite does not have boolean)
    };
  }

  // Create a User from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profilePicture: map['profile_picture'],
      isMe: map['is_me'] == 1,
      events: [], // Events should be fetched separately
    );
  }
}
