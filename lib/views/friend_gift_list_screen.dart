import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../widgets/gift_list_base.dart';

class FriendsGiftListPage extends StatefulWidget {
  const FriendsGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendsGiftListPage> createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Gift> gifts;
  late String eventName;
  late String eventDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    eventName = args['eventName'] ?? 'Event';
    eventDate = args['eventDate'] ?? 'Unknown Date';
    gifts = List<Gift>.from(args['gifts'] ?? []);
  }

  void _pledgeGift(int index) {
    setState(() {
      gifts[index].status = 'Pledged';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You pledged to buy "${gifts[index].name}"'),
      ),
    );
  }

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
      canPledge: true,
      onPledgeGift: _pledgeGift,
      onSort: _sortGifts,
    );
  }
}
