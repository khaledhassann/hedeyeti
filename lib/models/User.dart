import 'package:hedeyeti/models/Event.dart';

class User {
  String name;
  String email;
  String profilePicture;
  List<Event> events;

  User({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.events,
  });
}
