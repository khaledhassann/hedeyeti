// User.dart

class LocalUser {
  final String id; // Unified ID as a String (Firestore ID)
  String name;
  String email;
  String profilePicture;
  bool isMe;
  bool notificationPush;

  LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.isMe,
    required this.notificationPush,
  });

  // Parse from SQLite map
  factory LocalUser.fromSQLite(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id'] as String, // Now a String
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      profilePicture: map['profilePicture'] ?? 'assets/images.png',
      isMe: map['isMe'] == 1, // SQLite stores booleans as integers
      notificationPush:
          map['notificationPush'] == 1, // SQLite stores booleans as integers
    );
  }

  // Parse from Firestore document
  factory LocalUser.fromFirestore(Map<String, dynamic> map, String id) {
    return LocalUser(
      id: id, // Directly use Firestore ID as String
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'No Email',
      profilePicture: map['profilePicture'] ?? 'assets/images.png',
      isMe: false, // Firestore users are friends, not the logged-in user
      notificationPush: map['notificationPush'] == true,
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
      'notificationPush':
          notificationPush ? 1 : 0, // Store booleans as integers
    };
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'notificationPush': notificationPush,
    };
  }
}
