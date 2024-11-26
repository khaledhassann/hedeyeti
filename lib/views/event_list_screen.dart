import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import '../widgets/deletion_confirmation_dialog.dart';
import '../widgets/empty_list_message.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatelessWidget {
  static const routeName = '/events';

  @override
  Widget build(BuildContext context) {
    // Retrieve the passed arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String friendName = args['name'] ?? 'Friend';
    final List<Event> events = List<Event>.from(args['events'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text("$friendName's Events"),
      ),
      body: events.isEmpty
          ? const EmptyListMessage(
              message: 'No events yet!',
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/friends-gift-list',
                      arguments: {
                        'eventName': event.name,
                        'eventDate': event.formattedDate,
                        'gifts': event.gifts,
                      },
                    );
                  },
                  onPopupSelected: (value) {
                    if (value == 'Edit') {
                      Navigator.pushNamed(
                        context,
                        '/create-edit-event',
                        arguments: event,
                      );
                    } else if (value == 'Delete') {
                      _confirmDelete(context, event.name, index, events);
                    }
                  },
                );
              },
            ),
    );
  }

  void _confirmDelete(
      BuildContext context, String eventName, int index, List events) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ConfirmationDialog(
          title: 'Delete Event',
          content: 'Are you sure you want to delete "$eventName"?',
          onConfirm: () {
            events.removeAt(index); // Remove the event
            (context as Element).markNeedsBuild(); // Rebuild the UI
          },
        );
      },
    );
  }
}
