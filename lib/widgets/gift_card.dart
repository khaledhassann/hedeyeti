import 'package:flutter/material.dart';

class GiftCard extends StatelessWidget {
  final Map<String, dynamic> gift;
  final VoidCallback onPledge;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? pledgerName;

  const GiftCard({
    super.key,
    required this.gift,
    required this.onPledge,
    required this.onTap,
    this.onDelete,
    this.pledgerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(
              gift['status'] == 'Pledged'
                  ? Icons.check_circle
                  : Icons.card_giftcard,
              color: gift['status'] == 'Pledged' ? Colors.green : Colors.blue,
            ),
            title: Text(gift['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${gift['category']}'),
                Text('Price: \$${gift['price']}'),
                Text('Due date: ${gift['due_date']}'),
                if (pledgerName != null) Text('Pledged by: $pledgerName'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (gift['status'] != 'Pledged')
                  TextButton(
                    onPressed: onPledge,
                    child: const Text('Pledge'),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete Gift',
                  ),
              ],
            ),
          ),
          // Visual Cue for Unpublished Gift
          if (gift['is_published'] == false) // Assuming this property exists
            Positioned(
              top: 5,
              right: 5,
              child: const Icon(
                Icons.cloud_off_outlined,
                color: Colors.orange,
              ),
            ),
          if (gift['is_published'] == true) // Assuming this property exists
            Positioned(
              top: 5,
              right: 5,
              child: const Icon(
                Icons.cloud_done_outlined,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
