import 'package:flutter/material.dart';
import '../widgets/event_header.dart';
import '../widgets/gift_card.dart';
import '../widgets/empty_list_message.dart';

class FriendsGiftListPage extends StatefulWidget {
  const FriendsGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendsGiftListPage> createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Map<String, dynamic>> gifts;
  late String eventName;
  late String eventDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
          EventHeader(eventName: eventName, eventDate: eventDate),

          // Gift List or Empty Message
          Expanded(
            child: gifts.isEmpty
                ? const EmptyListMessage(
                    message: 'No gifts available for this event.',
                  )
                : ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      return GiftCard(
                        gift: gifts[index],
                        onPledge: () => _pledgeGift(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
