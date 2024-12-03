// FriendsGiftListPage.dart

import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../services/database_helper.dart';
import '../widgets/gift_list_base.dart';

class FriendsGiftListPage extends StatefulWidget {
  static const routeName = '/friends-gift-list';

  const FriendsGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendsGiftListPage> createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Gift> gifts = []; // List of gifts for the event
  final DatabaseHelper _dbHelper = DatabaseHelper(); // SQLite database helper

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is List<Gift>) {
      setState(() {
        gifts = args;
      });
    } else {
      // Handle invalid or missing arguments
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No gifts provided.')),
      );
    }
  }

  /// Updates the gift's status to 'Pledged' and persists the change in SQLite
  Future<void> _pledgeGift(int index) async {
    final gift = gifts[index];
    final updatedGift = Gift(
      id: gift.id,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: 'Pledged',
      eventId: gift.eventId,
      pledgerId:
          gift.pledgerId, // You might want to set this to the current user's ID
    );

    // Update the database with the new status
    await _dbHelper.updateGift(updatedGift.id, updatedGift.toSQLite());

    // Update the UI
    setState(() {
      gifts[index] = updatedGift;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend\'s Gifts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortGifts,
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return {'Name', 'Category', 'Status'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text('Sort by $choice'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: gifts.isEmpty
          ? const Center(
              child: Text(
                'No gifts to display.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GiftListBase(
              title: 'Friend\'s Gifts',
              gifts: gifts,
              canPledge: true, // Allow pledging gifts
              onPledgeGift: _pledgeGift,
              onSort: _sortGifts,
            ),
    );
  }
}
