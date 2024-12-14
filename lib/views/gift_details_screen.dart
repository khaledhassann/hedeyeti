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

  Widget _buildIconDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildIconDetailRow(Icons.card_giftcard, 'Gift Name', args.name),
          _buildIconDetailRow(Icons.category, 'Category', args.category),
          _buildIconDetailRow(Icons.attach_money, 'Price', '\$${args.price}'),
          _buildIconDetailRow(
            Icons.description,
            'Description',
            args.description ?? 'No description provided',
          ),
          _buildIconDetailRow(Icons.info_outline, 'Status', args.status),
          if (pledgerName != null)
            _buildIconDetailRow(Icons.person, 'Pledged by', pledgerName!),
        ],
      ),
    );
  }
}
