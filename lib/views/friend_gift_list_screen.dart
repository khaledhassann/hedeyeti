import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../services/database_helper.dart';
import '../widgets/gift_list_base.dart';

class FriendsGiftListPage extends StatefulWidget {
  const FriendsGiftListPage({Key? key}) : super(key: key);
  static const routeName = '/friends-gift-list';

  @override
  State<FriendsGiftListPage> createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Gift> gifts = []; // List of gifts for the event
  late String eventName; // Name of the event
  late String eventDate; // Date of the event
  late int eventId; // ID of the event
  final DatabaseHelper _dbHelper = DatabaseHelper(); // SQLite database helper

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    eventName = args['eventName'] ?? 'Event'; // Event name
    eventDate = args['eventDate'] ?? 'Unknown Date'; // Event date
    eventId = args['eventId']; // Event ID (must be provided)

    // Load gifts for this event from the database
    _loadGifts();
  }

  /// Fetches gifts for the given event ID from the SQLite database
  Future<void> _loadGifts() async {
    final giftMaps =
        await _dbHelper.getGiftsForEvent(eventId); // Query gifts by eventId
    setState(() {
      gifts = giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
    });
  }

  /// Updates the gift's status to 'Pledged' and persists the change in SQLite
  Future<void> _pledgeGift(int index) async {
    final gift = gifts[index];
    gift.status = 'Pledged';

    // Update the database with the new status
    await _dbHelper.updateGift(gift.id!, gift.toMap());

    // Update the UI
    setState(() {
      gifts[index] = gift;
    });

    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You pledged to buy "${gifts[index].name}"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Sorts the gifts list based on the selected criteria
  void _sortGifts(String sortBy) {
    setState(() {
      if (sortBy == 'Name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortBy == 'Category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortBy == 'Status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GiftListBase(
      title: '$eventName Gifts',
      gifts: gifts,
      canPledge: true, // Allow pledging gifts
      onPledgeGift: _pledgeGift,
      onSort: _sortGifts,
    );
  }
}
