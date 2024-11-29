import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/utils/constants.dart';
import 'package:hedeyeti/views/create_edit_gift_screen.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  static const routeName = '/pledged-gifts';
  final List<Gift> pledgedGifts = EXAMPLE_PLEDGED_GIFTS;

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
                      '${gift.description}\nPrice: \$${gift.price}\nDue: ${EXAMPLE_EVENTS[0].formattedDate}',
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
                              'name': gift.name,
                              'description': gift.description,
                              'price': gift.price,
                              'category': gift.category,
                              'status': gift.status == 'Pending'
                                  ? 'Available'
                                  : 'Pledged',
                            },
                          );
                        } else if (value == 'Cancel') {
                          // Handle pledge cancellation
                          _confirmCancel(context, gift.name);
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

  void _confirmCancel(BuildContext context, String giftName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cancel Pledge'),
          content: Text(
              'Are you sure you want to cancel your pledge for "$giftName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement cancellation logic
                Navigator.of(ctx).pop();
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
