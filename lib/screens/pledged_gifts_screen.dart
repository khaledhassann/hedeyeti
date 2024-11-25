import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> pledgedGifts = [
    {
      'friendName': 'John Doe',
      'giftName': 'Smartphone',
      'description': 'Latest model smartphone',
      'price': 799.99,
      'dueDate': '2024-12-15',
      'status': 'Pending',
      'category': 'Electronics', // Added category for consistency
    },
    {
      'friendName': 'Jane Smith',
      'giftName': 'Headphones',
      'description': 'Noise-canceling headphones',
      'price': 199.99,
      'dueDate': '2024-11-30',
      'status': 'Completed',
      'category': 'Accessories', // Added category for consistency
    },
  ];

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
                      gift['status'] == 'Completed'
                          ? Icons.check_circle
                          : Icons.pending,
                      color: gift['status'] == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(gift['giftName']),
                    subtitle: Text(
                      '${gift['description']}\nPrice: \$${gift['price']}\nDue: ${gift['dueDate']}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          // Navigate to Create/Edit Gift Page with gift data
                          Navigator.pushNamed(
                            context,
                            '/create-edit-gift',
                            arguments: {
                              'name': gift['giftName'],
                              'description': gift['description'],
                              'price': gift['price'],
                              'category': gift['category'],
                              'status': gift['status'] == 'Pending'
                                  ? 'Available'
                                  : 'Pledged',
                            },
                          );
                        } else if (value == 'Cancel') {
                          // Handle pledge cancellation
                          _confirmCancel(context, gift['giftName']);
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
