import 'package:hedeyeti/models/Gift.dart';

class Event {
  String name;
  DateTime date;
  String category;
  List<Gift> gifts;

  Event({
    required this.name,
    required this.date,
    required this.category,
    required this.gifts,
  });
}
