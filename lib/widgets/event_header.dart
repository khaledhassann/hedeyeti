import 'package:flutter/material.dart';

class EventHeader extends StatelessWidget {
  final String eventName;
  final String eventDate;

  const EventHeader({
    super.key,
    required this.eventName,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Gifts for $eventName on $eventDate',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
