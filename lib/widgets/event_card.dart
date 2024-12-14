import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import '../views/event_details_screen.dart'; // Import event details page

class EventCard extends StatelessWidget {
  final Event event;
  final void Function() onTap;
  final void Function(String) onPopupSelected;
  final bool isEditable;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onPopupSelected,
    required this.isEditable, // Indicates if the card is editable
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        title: Text(event.name),
        subtitle: Text("Date: ${event.formattedDate}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  EventDetailsPage.routeName,
                  arguments: {'eventId': event.id}, // Pass the event ID
                );
              },
              tooltip: 'View Details',
            ),
            if (isEditable)
              PopupMenuButton<String>(
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
          ],
        ),
      ),
    );
  }
}
