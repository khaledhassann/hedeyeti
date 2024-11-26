import 'package:flutter/material.dart';
import '../widgets/deletion_confirmation_dialog.dart';
import '../widgets/empty_list_message.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatelessWidget {
  static const routeName = '/events';

  @override
  Widget build(BuildContext context) {
    final friend =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final events = friend['events'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("${friend['name']}'s Events"),
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
                        'eventName': event['name'],
                        'eventDate': event['date'],
                        'gifts': event['gifts'],
                      },
                    );
                  },
                  onPopupSelected: (value) {
                    if (value == 'Edit') {
                      final eventData = {
                        ...event,
                        'category': event['category'] ?? 'Uncategorized',
                      };

                      Navigator.pushNamed(
                        context,
                        '/create-edit-event',
                        arguments: eventData,
                      );
                    } else if (value == 'Delete') {
                      _confirmDelete(context, event['name'], index, events);
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
            events.removeAt(index);
            (context as Element).markNeedsBuild();
          },
        );
      },
    );
  }
}
