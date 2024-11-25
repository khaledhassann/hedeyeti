import 'package:flutter/material.dart';

class FriendsGiftListPage extends StatefulWidget {
  const FriendsGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendsGiftListPage> createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Map<String, dynamic>> gifts; // List of gifts for the event
  late String eventName; // Name of the event
  late String eventDate; // Date of the event

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed from the Event List Page
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    eventName = args['eventName'] ?? 'Event';
    eventDate = args['eventDate'] ?? 'Unknown Date';
    gifts = List<Map<String, dynamic>>.from(args['gifts'] ?? []);
  }

  void _pledgeGift(int index) {
    setState(() {
      gifts[index]['status'] = 'Pledged';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You pledged to buy "${gifts[index]['name']}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$eventName Gifts'),
      ),
      body: Column(
        children: [
          // Event Details Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gifts for $eventName on $eventDate',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: gifts.isEmpty
                ? const Center(
                    child: Text(
                      'No gifts available for this event.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: Icon(
                            gift['status'] == 'Pledged'
                                ? Icons.check_circle
                                : Icons.card_giftcard,
                            color: gift['status'] == 'Pledged'
                                ? Colors.green
                                : Colors.blue,
                          ),
                          title: Text(gift['name']),
                          subtitle: Text(
                            'Category: ${gift['category']}\nPrice: \$${gift['price']}',
                          ),
                          isThreeLine: true,
                          trailing: gift['status'] != 'Pledged'
                              ? TextButton(
                                  onPressed: () => _pledgeGift(index),
                                  child: const Text('Pledge'),
                                )
                              : null,
                          onTap: () {
                            // Optional: Navigate to a Gift Details Page
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
