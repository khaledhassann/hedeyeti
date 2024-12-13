// Gift.dart

class Gift {
  String id; // Unified ID as a String (Firestore ID)
  String name;
  String? description;
  String category;
  double price;
  String status; // Available, Pledged, Completed
  String eventId; // ID of the associated Event (String)
  String? pledgerId; // ID of the user who pledged for this gift (String)

  Gift({
    required this.id, // Now required and non-nullable
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
    this.pledgerId,
  });

  /// Factory constructor to create Gift from a Map (e.g., SQLite)
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as String, // Ensure id is a String
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String,
      eventId: map['event_id'] as String,
      pledgerId: map['pledger_id'] as String?,
    );
  }

  /// Factory constructor to create Gift from Firestore Document
  factory Gift.fromFirestore(Map<String, dynamic> map, String id) {
    return Gift(
      id: id, // Use Firestore ID directly as String
      name: map['name'] as String? ?? 'Unnamed Gift',
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'Uncategorized',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Available',
      eventId:
          map['event_id'] as String, // Ensure this is provided in Firestore
      pledgerId: map['pledger_id'] as String?,
    );
  }

  /// Convert Gift to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Now a String
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'pledger_id': pledgerId,
    };
  }

  /// Convert Gift to a Map for SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id, // Now a String
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'pledger_id': pledgerId,
    };
  }

  /// Convert Gift to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'pledger_id': pledgerId,
    };
  }

  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    String? eventId,
    String? pledgerId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      pledgerId: pledgerId ?? this.pledgerId,
    );
  }
}
