import 'package:flutter/material.dart';

class GiftCard extends StatelessWidget {
  final Map<String, dynamic> gift;
  final VoidCallback onPledge;

  const GiftCard({
    super.key,
    required this.gift,
    required this.onPledge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          gift['status'] == 'Pledged'
              ? Icons.check_circle
              : Icons.card_giftcard,
          color: gift['status'] == 'Pledged' ? Colors.green : Colors.blue,
        ),
        title: Text(gift['name']),
        subtitle: Text(
          'Category: ${gift['category']}\nPrice: \$${gift['price']}',
        ),
        isThreeLine: true,
        trailing: gift['status'] != 'Pledged'
            ? TextButton(
                onPressed: onPledge,
                child: const Text('Pledge'),
              )
            : null,
        onTap: () {
          // Optional: Navigate to Gift Details
        },
      ),
    );
  }
}
