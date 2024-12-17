// Event.dart

class Event {
  String id; // Unified ID as a String (Firestore ID)
  String name;
  DateTime date;
  String category;
  String location;
  String description;
  String userId;
  bool isPublished;

  Event({
    required this.id, // Now required and non-nullable
    required this.name,
    required this.date,
    required this.category,
    required this.location,
    required this.description,
    required this.userId,
    required this.isPublished,
  });

  /// Getter for formatted date
  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  /// Factory constructor to create Event from a Map (e.g., SQLite)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String, // Ensure id is a String
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      location: map['location'] as String? ?? 'No Location', // Handle null
      description:
          map['description'] as String? ?? 'No Description', // Handle null
      userId: map['userId'] as String,
      isPublished: map['isPublished'] as bool,
    );
  }

  /// Factory constructor to create Event from SQLite Map
  factory Event.fromSQLite(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      location: map['location'] as String? ?? 'No Location', // Handle null
      description:
          map['description'] as String? ?? 'No Description', // Handle null
      userId: map['user_id'] as String,
      isPublished: map['is_published'] == 1,
    );
  }

  /// Factory constructor to create Event from Firestore Document
  factory Event.fromFirestore(Map<String, dynamic> map, String id) {
    return Event(
      id: id, // Use Firestore ID directly as String
      name: map['name'] as String? ?? 'Unnamed Event',
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String? ?? 'Uncategorized',
      location: map['location'] as String? ?? 'No Location', // Handle null
      description:
          map['description'] as String? ?? 'No Description', // Handle null
      userId: map['userId'] as String,
      isPublished: true,
    );
  }

  /// Convert Event to Map (if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Now a String
      'name': name,
      'date': date.toIso8601String(),
      'category': category,
      'location': location,
      'description': description,
      'userId': userId,
      'isPublished': isPublished,
      // 'gifts': gifts.map((gift) => gift.toMap()).toList(), // If gifts need to be stored
    };
  }

  /// Convert Event to a Map for SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id, // Now a String
      'name': name,
      'date': date.toIso8601String(),
      'category': category,
      'location': location,
      'description': description,
      'user_id': userId,
      'is_published': isPublished ? 1 : 0,
      // Gifts are excluded; stored in their own table
    };
  }

  /// Convert Event to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'category': category,
      'location': location,
      'description': description,
      'userId': userId,
      // Exclude ID as Firestore generates its own
    };
  }
}
