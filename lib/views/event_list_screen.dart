// EventListPage.dart
import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/friend_gift_list_screen.dart';
import '../services/firebase_helper.dart';
import '../widgets/deletion_confirmation_dialog.dart';
import '../widgets/empty_list_message.dart';
import '../widgets/event_card.dart';
import '../services/database_helper.dart'; // Import DatabaseHelper

class EventListPage extends StatefulWidget {
  static const routeName = '/events';

  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late String friendId; // Changed from friendName to friendId
  late String friendName; // Retain friendName for display
  List<Event> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  /// Fetches the events for the specified friend from the local SQLite database.
  void _loadEvents() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      friendId = args['id'] as String? ?? '';
      friendName = args['name'] as String? ?? 'Friend';

      if (friendId.isEmpty) {
        // Handle missing friendId
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Friend ID is missing')),
        );
        return;
      }

      // Fetch events from the database using friendId
      final eventMaps = await _dbHelper.getEventsForUser(friendId);

      setState(() {
        _events = eventMaps.map((e) => Event.fromMap(e)).toList();
      });
    } else {
      // Handle invalid arguments
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid arguments')),
      );
    }
  }

  /// Deletes an event and updates the UI accordingly.
  Future<void> _deleteEvent(String eventId, int index) async {
    await _dbHelper.deleteEvent(eventId);
    setState(() {
      _events.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event deleted successfully'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$friendName's Events"),
      ),
      body: _events.isEmpty
          ? const EmptyListMessage(
              message: 'No events yet!',
            )
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];

                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      FriendsGiftListPage.routeName,
                      arguments: _firebaseHelper.getGiftsForEventFromFirestore(
                          event.id), // Pass the entire Event object
                    );
                  },
                  onPopupSelected: (value) {
                    if (value == 'Edit') {
                      Navigator.pushNamed(
                        context,
                        CreateEditEventPage.routeName,
                        arguments: event, // Pass the entire Event object
                      ).then((_) => _loadEvents());
                    } else if (value == 'Delete') {
                      _confirmDelete(context, event.id, event.name, index);
                    }
                  },
                );
              },
            ),
    );
  }

  /// Shows a confirmation dialog before deleting an event.
  void _confirmDelete(
      BuildContext context, String? eventId, String eventName, int index) {
    if (eventId == null || eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Event ID is missing')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return ConfirmationDialog(
          title: 'Delete Event',
          content: 'Are you sure you want to delete "$eventName"?',
          onConfirm: () {
            _deleteEvent(eventId, index);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }
}
