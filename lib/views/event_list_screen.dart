import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/friend_gift_list_screen.dart';
import '../widgets/deletion_confirmation_dialog.dart';
import '../widgets/empty_list_message.dart';
import '../widgets/event_card.dart';
import '../services/database_helper.dart'; // Import DatabaseHelper

class EventListPage extends StatefulWidget {
  static const routeName = '/events';

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late String friendName;
  List<Event> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  void _loadEvents() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    friendName = args['name'] ?? 'Friend';

    // Fetch events from the database
    final eventMaps = await _dbHelper.getEventsForUser(friendName);

    setState(() {
      _events = eventMaps.map((e) => Event.fromMap(e)).toList();
    });
  }

  Future<void> _deleteEvent(int eventId, int index) async {
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
                        CreateEditEventPage.routeName,
                        arguments: event.toMap(),
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

  void _confirmDelete(
      BuildContext context, int? eventId, String eventName, int index) {
    if (eventId == null) {
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
