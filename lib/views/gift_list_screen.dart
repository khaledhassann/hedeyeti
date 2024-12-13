import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/LocalUser.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/views/create_edit_gift_screen.dart';
import 'package:hedeyeti/views/gift_details_screen.dart';
import '../widgets/gift_list_base.dart';

class GiftListPage extends StatefulWidget {
  static const routeName = '/gift-list';

  const GiftListPage({Key? key}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  List<Gift> gifts = [];
  bool isMyList = false; // Whether the gifts belong to the logged-in user
  String title = 'Gifts'; // Dynamic title for the page
  String? userId; // ID of the logged-in user
  String? ownerId; // Owner's ID
  String? eventId; // Event ID for the gift list

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      eventId = args['eventId'] as String? ?? '';
      ownerId = args['ownerId'] as String? ?? '';

      final currentUser = await _firebaseHelper.getCurrentUser();
      userId = currentUser?.id;

      if (eventId == null || ownerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing event or owner data.')),
        );
        return;
      }

      // Determine if the list belongs to the current user
      setState(() {
        isMyList = ownerId == userId;
      });

      // Fetch the owner's name
      final ownerData = await _firebaseHelper.getUserFromFirestore(ownerId!);
      setState(() {
        title =
            isMyList ? 'My Gifts' : "${ownerData?.name ?? "Friend"}'s Gifts";
      });

      // Fetch gifts for the event
      final fetchedGifts =
          await _firebaseHelper.getGiftsForEventFromFirestore(eventId!);
      setState(() {
        gifts = fetchedGifts ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid arguments.')),
      );
    }
  }

  /// Handles pledging a gift.
  Future<void> _pledgeGift(int index) async {
    final gift = gifts[index];

    // Update the gift with the logged-in user's ID as the pledger
    await _firebaseHelper.updateGiftInFirestore(
      giftId: gift.id,
      status: 'Pledged',
      pledgerId: userId,
    );

    setState(() {
      gifts[index] = gift.copyWith(
        status: 'Pledged',
        pledgerId: userId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You pledged to buy "${gifts[index].name}"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Sorts the gifts list based on the selected criteria.
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

  /// Handles gift card click events.
  void _onGiftTap(int index) {
    final gift = gifts[index];
    if (isMyList) {
      Navigator.pushNamed(
        context,
        CreateEditGiftPage.routeName,
        arguments: {
          'gift': gift,
          'eventId': gift.eventId
        }, // Navigate to edit gift screen
      ).then((_) => _loadData());
    } else {
      Navigator.pushNamed(
        context,
        GiftDetailsPage.routeName,
        arguments: gift, // Navigate to view gift details
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GiftListBase(
        title: title,
        gifts: gifts,
        canEdit: isMyList, // Allow editing only for user's gifts
        canPledge: !isMyList, // Allow pledging only for friend's gifts
        onPledgeGift: _pledgeGift,
        onSort: _sortGifts,
        onGiftTap: _onGiftTap, // Handle tapping a gift
        showAddButton: isMyList,
        onAddGift: () {
          // Pass eventId when creating a new gift
          Navigator.pushNamed(
            context,
            CreateEditGiftPage.routeName,
            arguments: {'eventId': eventId},
          ).then((_) => _loadData());
        },
      ),
    );
  }
}
