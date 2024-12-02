import 'Gift.dart';

class Event {
  int? id; // Primary key for SQLite
  String name;
  DateTime date;
  String category;
  List<Gift> gifts;

  Event({
    this.id, // Nullable to handle new events
    required this.name,
    required this.date,
    required this.category,
    required this.gifts,
  });

  // Custom getter to return formatted date
  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  // Convert Event to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'category': category,
      // Exclude gifts as they should be stored in their own table
    };
  }

  // Create an Event from a Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      gifts: [], // Gifts should be fetched separately
    );
  }
}
