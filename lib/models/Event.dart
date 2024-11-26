// ignore_for_file: prefer_final_fields

import 'package:hedeyeti/models/Gift.dart';

class Event {
  String name;
  DateTime _date;
  String category;
  List<Gift> gifts;

  Event({
    required this.name,
    required DateTime date,
    required this.category,
    required this.gifts,
  }) : _date = date;

  // Custom getter to return only the date part
  DateTime get date => DateTime(_date.year, _date.month, _date.day);

  String get formattedDate =>
      "${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}";
}
