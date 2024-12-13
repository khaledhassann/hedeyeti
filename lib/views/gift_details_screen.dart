import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/services/firebase_helper.dart';

class GiftDetailsPage extends StatefulWidget {
  static const routeName = '/gift-details';

  const GiftDetailsPage({Key? key}) : super(key: key);

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  late Gift gift;
  bool isPledged = false; // Tracks whether the gift is already pledged
  String? userId; // Logged-in user's ID

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeGiftDetails();
  }

  Future<void> _initializeGiftDetails() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Gift) {
      setState(() {
        gift = args;
        isPledged = gift.status == 'Pledged';
      });

      // Fetch logged-in user's ID
      final currentUser = await _firebaseHelper.getCurrentUser();
      setState(() {
        userId = currentUser?.id;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Gift details are missing.')),
      );
      Navigator.pop(context);
    }
  }

  /// Handles the pledging of a gift.
  Future<void> _pledgeGift() async {
    if (isPledged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already pledged this gift.')),
      );
      return;
    }

    try {
      await _firebaseHelper.updateGiftInFirestore(
        giftId: gift.id,
        status: 'Pledged',
        pledgerId: userId,
      );

      setState(() {
        isPledged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You pledged to buy "${gift.name}"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error pledging the gift. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
      ),
      body: gift == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category: ${gift.category}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    gift.description?.isNotEmpty == true
                        ? gift.description!
                        : 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price: \$${gift.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (!isPledged)
                    ElevatedButton.icon(
                      onPressed: _pledgeGift,
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('Pledge Gift'),
                    ),
                  if (isPledged)
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: const Text('Gift Pledged'),
                    ),
                ],
              ),
            ),
    );
  }
}
