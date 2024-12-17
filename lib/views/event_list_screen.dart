import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/gift_list_screen.dart';
import '../services/database_helper.dart';
import '../services/firebase_helper.dart';
import '../widgets/deletion_confirmation_dialog.dart';
import '../widgets/empty_list_message.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatefulWidget {
  static const routeName = '/events';

  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String? _currentUserId;
  String? _friendId;
  String _title = 'Events';
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    final currentUser = await _firebaseHelper.getCurrentUser();
    setState(() {
      _currentUserId = currentUser?.id;
    });

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _friendId = args['id'] as String?;
      final friendName = args['name'] as String? ?? 'Friend';

      setState(() {
        _title =
            _friendId == _currentUserId ? 'My Events' : "$friendName's Events";
      });

      await _loadEvents();
    }
  }

  // Future<void> _loadEvents() async {
  //   if (_friendId != null) {
  //     final events =
  //         await _firebaseHelper.getEventsForUserFromFireStore(_friendId!);
  //     setState(() {
  //       _events = events ?? [];
  //     });
  //   }
  // }
  // Future<void> _loadEvents() async {
  //   final dbHelper = DatabaseHelper();
  //   List<Event> localEvents = (await dbHelper.getEventsForUser(_currentUserId!))
  //       .map((e) => Event.fromSQLite(e))
  //       .toList();

  //   final remoteEvents =
  //       await _firebaseHelper.getEventsForUserFromFireStore(_currentUserId!);

  //   // Combine local and remote events
  // final combinedEvents = [
  //   ...localEvents,
  //   if (remoteEvents != null)
  //     ...remoteEvents.where((remoteEvent) => !localEvents.any(
  //           (localEvent) => localEvent.id == remoteEvent.id,
  //         )),
  // ];

  //   setState(() {
  //     _events = combinedEvents;
  //   });
  // }

  Future<void> _loadEvents() async {
    final dbHelper = DatabaseHelper();

    if (_friendId != null) {
      if (_friendId == _currentUserId) {
        // Load events for the logged-in user (local + Firestore)
        List<Event> localEvents =
            (await dbHelper.getEventsForUser(_currentUserId!))
                .map((e) => Event.fromSQLite(e))
                .toList();

        final remoteEvents = await _firebaseHelper
            .getEventsForUserFromFireStore(_currentUserId!);

        // Combine local and remote events, avoiding duplicates
        final combinedEvents = [
          ...localEvents,
          if (remoteEvents != null)
            ...remoteEvents.where((remoteEvent) => !localEvents.any(
                  (localEvent) => localEvent.id == remoteEvent.id,
                )),
        ];

        setState(() {
          _events = combinedEvents;
        });
      } else {
        // Load events for a friend (only Firestore)
        final friendEvents =
            await _firebaseHelper.getEventsForUserFromFireStore(_friendId!);

        setState(() {
          _events = friendEvents ?? [];
        });
      }
    }
  }

  Future<void> _deleteEvent(String eventId, int index) async {
    await _firebaseHelper.deleteEventInFirestore(eventId);
    await _databaseHelper.deleteEvent(eventId);
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
      appBar: AppBar(title: Text(_title)),
      body: _events.isEmpty
          ? const EmptyListMessage(message: 'No events yet!')
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                final isMyEvent = event.userId == _currentUserId;

                return EventCard(
                  event: event,
                  onTap: () {
                    // Navigate to gift list regardless of ownership
                    Navigator.pushNamed(
                      context,
                      GiftListPage.routeName,
                      arguments: {
                        'eventId': event.id,
                        'ownerId': event.userId,
                      },
                    );
                  },
                  onPopupSelected: (value) {
                    if (isMyEvent) {
                      // Only allow editing and deleting for the current user's events
                      if (value == 'Edit') {
                        Navigator.pushNamed(
                          context,
                          CreateEditEventPage.routeName,
                          arguments: event,
                        ).then((_) => _loadEvents());
                      } else if (value == 'Delete') {
                        _confirmDelete(context, event.id, event.name, index);
                      }
                    }
                  },
                  isEditable:
                      isMyEvent, // Pass ownership information to the card
                );
              },
            ),
    );
  }

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
