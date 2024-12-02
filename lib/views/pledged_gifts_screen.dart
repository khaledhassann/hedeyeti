import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../services/database_helper.dart';
import '../views/create_edit_gift_screen.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  static const routeName = '/pledged-gifts';

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  late List<Gift> pledgedGifts = []; // List of pledged gifts
  final DatabaseHelper _dbHelper = DatabaseHelper(); // SQLite helper

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts(); // Load pledged gifts on initialization
  }

  /// Fetches all gifts with the status 'Pledged' from the database
  Future<void> _loadPledgedGifts() async {
    final giftMaps = await _dbHelper.getPledgedGifts(); // Query SQLite
    setState(() {
      pledgedGifts = giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
    });
  }

  /// Confirms and cancels a gift pledge, updating the database
  void _confirmCancel(BuildContext context, Gift gift) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cancel Pledge'),
          content: Text(
              'Are you sure you want to cancel your pledge for "${gift.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Update gift status in the database
                gift.status = 'Available';
                await _dbHelper.updateGift(gift.id!, gift.toMap());

                // Reload the UI
                _loadPledgedGifts();

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pledge for "${gift.name}" canceled.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: pledgedGifts.isEmpty
          ? const Center(
              child: Text(
                'No pledged gifts yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = pledgedGifts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      gift.status == 'Completed'
                          ? Icons.check_circle
                          : Icons.pending,
                      color: gift.status == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(gift.name),
                    subtitle: Text(
                      '${gift.description}\nPrice: \$${gift.price}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          // Navigate to Create/Edit Gift Page with gift data
                          Navigator.pushNamed(
                            context,
                            CreateEditGiftPage.routeName,
                            arguments: {
                              'id': gift.id,
                              'name': gift.name,
                              'description': gift.description,
                              'price': gift.price,
                              'category': gift.category,
                              'status': gift.status,
                              'eventId': gift.eventId,
                            },
                          ).then((_) =>
                              _loadPledgedGifts()); // Reload gifts on return
                        } else if (value == 'Cancel') {
                          // Handle pledge cancellation
                          _confirmCancel(context, gift);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'Cancel',
                          child: Text('Cancel Pledge'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
