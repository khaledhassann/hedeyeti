// import 'package:flutter/material.dart';
// import 'package:hedeyeti/models/Gift.dart';
// import '../services/database_helper.dart';
// import '../widgets/gift_list_base.dart';
// import '../views/create_edit_gift_screen.dart';

// class GiftListPage extends StatefulWidget {
//   static const routeName = '/gifts';
//   const GiftListPage({Key? key}) : super(key: key);

//   @override
//   State<GiftListPage> createState() => _GiftListPageState();
// }

// class _GiftListPageState extends State<GiftListPage> {
//   late Future<List<Gift>> _giftsFuture;
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   late int _eventId; // Event ID passed to this screen
//   late int _loggedInUserId; // User ID passed to this screen

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Retrieve arguments from navigation
//     final args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     _eventId = args?['eventId'] ?? 0; // Event ID is required
//     _loggedInUserId =
//         args?['loggedInUserId'] ?? 0; // Logged-in user ID is required

//     // Fetch gifts for the given event
//     _giftsFuture = _fetchGifts();
//   }

//   Future<List<Gift>> _fetchGifts() async {
//     final giftMaps = await _dbHelper.getGiftsForEvent(_eventId);
//     return giftMaps.map((map) => Gift.fromMap(map)).toList();
//   }

//   void _addGift() async {
//     final result = await Navigator.pushNamed(
//       context,
//       CreateEditGiftPage.routeName,
//       arguments: {'eventId': _eventId, 'loggedInUserId': _loggedInUserId},
//     );

//     if (result != null) {
//       setState(() {
//         _giftsFuture = _fetchGifts();
//       });
//     }
//   }

//   void _editGift(int index, Gift gift) async {
//     final result = await Navigator.pushNamed(
//       context,
//       CreateEditGiftPage.routeName,
//       arguments: {
//         'id': gift.id,
//         'name': gift.name,
//         'description': gift.description,
//         'price': gift.price,
//         'category': gift.category,
//         'status': gift.status,
//         'eventId': _eventId,
//         'loggedInUserId': _loggedInUserId,
//       },
//     );

//     if (result != null) {
//       setState(() {
//         _giftsFuture = _fetchGifts();
//       });
//     }
//   }

//   void _deleteGift(int giftId) async {
//     await _dbHelper.deleteGift(giftId);
//     setState(() {
//       _giftsFuture = _fetchGifts();
//     });
//   }

//   void _sortGifts(String sortBy, List<Gift> gifts) {
//     setState(() {
//       if (sortBy == 'Name') {
//         gifts.sort((a, b) => a.name.compareTo(b.name));
//       } else if (sortBy == 'Category') {
//         gifts.sort((a, b) => a.category.compareTo(b.category));
//       } else if (sortBy == 'Status') {
//         gifts.sort((a, b) => a.status.compareTo(b.status));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Gift>>(
//       future: _giftsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(
//             child: Text('Failed to load gifts. Please try again later.'),
//           );
//         } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No gifts available for this event.'),
//           );
//         } else {
//           final gifts = snapshot.data!;
//           return GiftListBase(
//             title: 'Event Gifts',
//             gifts: gifts,
//             canEdit: true,
//             showAddButton: true,
//             onAddGift: _addGift,
//             onEditGift: (index) => _editGift(index, gifts[index]),
//             onDeleteGift: (index) => _deleteGift(gifts[index].id!),
//             onSort: (sortBy) => _sortGifts(sortBy, gifts),
//           );
//         }
//       },
//     );
//   }
// }
