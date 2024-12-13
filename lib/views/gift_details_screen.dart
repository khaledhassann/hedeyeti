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
  String? pledgerName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Gift?; // Get the gift
    if (args == null) {
      Navigator.pop(context);
      return;
    }

    // Fetch pledger's name if available
    if (args.pledgerId != null) {
      _fetchPledgerName(args.pledgerId).then((name) {
        if (mounted) {
          setState(() {
            pledgerName = name;
          });
        }
      });
    }
  }

  Future<String?> _fetchPledgerName(String? pledgerId) async {
    if (pledgerId == null) return null;

    try {
      final user = await _firebaseHelper.getUserFromFirestore(pledgerId);
      return user?.name;
    } catch (e) {
      print('Error fetching pledger name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Gift?; // Get the gift

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gift Details')),
        body: const Center(
          child: Text('No gift details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gift Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${args.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${args.category}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \$${args.price}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${args.description ?? "No description provided"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${args.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (pledgerName != null)
              Text(
                'Pledged by: $pledgerName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
