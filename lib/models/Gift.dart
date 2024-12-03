class Gift {
  int? id;
  String name;
  String? description;
  String category;
  double price;
  String status;
  int eventId;
  int? pledgerId;

  Gift({
    this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
    this.pledgerId,
  });

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['event_id'],
      pledgerId: map['pledger_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'pledger_id': pledgerId,
    };
  }
}
