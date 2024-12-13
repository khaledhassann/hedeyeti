import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/widgets/empty_list_message.dart';

class GiftListBase extends StatelessWidget {
  final String title;
  final List<Gift> gifts;
  final bool canEdit;
  final bool canPledge;
  final bool showAddButton;
  final VoidCallback? onAddGift;
  final Function(int index)? onPledgeGift;
  final Function(int index)? onViewGiftDetails;
  final Function(int index)? onGiftTap;
  final Function(int index)? onEditGift;
  final Function(int index)? onDeleteGift;
  final Function(String sortBy)? onSort;

  const GiftListBase({
    super.key,
    required this.title,
    required this.gifts,
    this.canEdit = false,
    this.canPledge = false,
    this.showAddButton = false,
    this.onAddGift,
    this.onPledgeGift,
    this.onViewGiftDetails,
    this.onGiftTap,
    this.onEditGift,
    this.onDeleteGift,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_outlined),
            onSelected: onSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'Category',
                child: Text('Sort by Category'),
              ),
              const PopupMenuItem(
                value: 'Status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: gifts.isEmpty
          ? const EmptyListMessage(message: 'No gifts for this event yet!')
          : ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () => onGiftTap?.call(index),
                    leading: CircleAvatar(
                      backgroundColor: gift.status == 'Pledged'
                          ? Colors.red[100]
                          : Colors.green[100],
                      child: Icon(
                        gift.status == 'Pledged'
                            ? Icons.check
                            : Icons.card_giftcard,
                        color: gift.status == 'Pledged'
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    title: Text(gift.name),
                    subtitle: Text(
                      'Category: ${gift.category} - \$${gift.price}',
                    ),
                    trailing: _buildActions(context, index, gift),
                  ),
                );
              },
            ),
      floatingActionButton: showAddButton
          ? FloatingActionButton(
              onPressed: onAddGift,
              tooltip: 'Add Gift',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget? _buildActions(BuildContext context, int index, Gift gift) {
    if (canEdit) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Edit') {
            onEditGift?.call(index);
          } else if (value == 'Delete') {
            onDeleteGift?.call(index);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'Edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: Text('Delete'),
          ),
        ],
      );
    }

    if (canPledge) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => onViewGiftDetails?.call(index),
            tooltip: 'View Details',
          ),
          if (gift.status != 'Pledged')
            TextButton(
              onPressed: () => onPledgeGift?.call(index),
              child: const Text('Pledge'),
            ),
        ],
      );
    }

    return null;
  }
}
