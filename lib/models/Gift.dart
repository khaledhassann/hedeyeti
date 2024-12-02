class Gift {
  int? id; // Primary key for SQLite
  String name;
  String category;
  double price;
  String status;
  String? description;
  int eventId; // Foreign key to link with Event

  Gift({
    this.id, // Nullable for new gifts
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    this.description,
    required this.eventId,
  });

  // Convert Gift to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'status': status,
      'description': description,
      'event_id': eventId, // Foreign key reference
    };
  }

  // Create a Gift from a Map
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      description: map['description'],
      eventId: map['event_id'],
    );
  }
}
