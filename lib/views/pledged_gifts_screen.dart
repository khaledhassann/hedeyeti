import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../services/firebase_helper.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  static const routeName = '/pledged-gifts';

  const MyPledgedGiftsPage({Key? key}) : super(key: key);

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  late Future<List<Gift>> _pledgedGiftsFuture;
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  String? userId;

  @override
  void initState() {
    super.initState();
    _pledgedGiftsFuture = _loadPledgedGifts(); // Initialize the future.
  }

  Future<List<Gift>> _loadPledgedGifts() async {
    final currentUser = await _firebaseHelper.getCurrentUser();
    userId = currentUser?.id;

    if (userId == null) {
      return []; // Return an empty list if no user is logged in.
    }

    final pledgedGifts =
        await _firebaseHelper.getPledgedGiftsFromUserFromFirestore(userId!);
    return pledgedGifts ?? [];
  }

  Future<void> _cancelPledge(Gift gift) async {
    try {
      await _firebaseHelper.updateGiftInFirestore(
        giftId: gift.id,
        status: 'Available',
        pledgerId: null,
      );
      setState(() {
        _pledgedGiftsFuture = _loadPledgedGifts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pledge for "${gift.name}" canceled successfully.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel pledge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: FutureBuilder<List<Gift>>(
        future: _pledgedGiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load pledged gifts. Please try again.'),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No pledged gifts yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final pledgedGifts = snapshot.data!;
            return ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = pledgedGifts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      Icons.card_giftcard,
                      color: Colors.green,
                    ),
                    title: Text(gift.name),
                    subtitle: Text(
                        'Category: ${gift.category}\nPrice: \$${gift.price}'),
                    trailing: TextButton(
                      onPressed: () => _cancelPledge(gift),
                      child: const Text(
                        'Cancel Pledge',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
