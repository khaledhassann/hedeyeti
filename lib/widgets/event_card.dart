import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final void Function() onTap;
  final void Function(String) onPopupSelected;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onPopupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        title: Text(event.name),
        subtitle: Text("Date: ${event.formattedDate}"),
        trailing: PopupMenuButton<String>(
          onSelected: onPopupSelected,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'Edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'Delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
