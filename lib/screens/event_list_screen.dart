import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  static const routeName = '/events';

  @override
  Widget build(BuildContext context) {
    // Retrieve the friend's data from arguments
    final friend =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final events = friend['events'] ?? []; // Get the events for the friend

    return Scaffold(
      appBar: AppBar(
        title: Text("${friend['name']}'s Events"),
      ),
      body: events.isEmpty
          ? const Center(
              child: Text(
                'No events found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/friends-gift-list',
                        arguments: {
                          'eventName': event['name'],
                          'eventDate': event['date'],
                          'gifts':
                              event['gifts'], // List of gifts for the event
                        },
                      );
                    },
                    title: Text(event['name']),
                    subtitle: Text("Date: ${event['date']}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          // Ensure the category key exists
                          final eventData = {
                            ...event,
                            'category': event['category'] ?? 'Uncategorized',
                          };
                          print("Passed Event Data: ${eventData.runtimeType}");

                          // Navigate to the Edit Event Page with complete data
                          Navigator.pushNamed(
                            context,
                            '/create-edit-event',
                            arguments: eventData,
                          );
                        } else if (value == 'Delete') {
                          // Handle delete functionality
                          _confirmDelete(context, event['name'], index, events);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
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
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "$eventName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                events.removeAt(index); // Remove the event
                Navigator.of(ctx).pop(); // Close the dialog
                (context as Element).markNeedsBuild(); // Refresh the UI
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
