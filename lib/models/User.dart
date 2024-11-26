import 'package:hedeyeti/models/Event.dart';

class User {
  String name;
  String email;
  String profilePicture;
  bool isMe;
  List<Event> events;

  User({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.isMe,
    required this.events,
  });
}
