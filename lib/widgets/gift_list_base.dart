import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/widgets/empty_list_message.dart';
import 'package:hedeyeti/widgets/gift_card.dart';

class GiftListBase extends StatelessWidget {
  final String title;
  final List<Gift> gifts;
  final bool canEdit;
  final bool canPledge;
  final bool showAddButton;
  final String? dueDate;
  final VoidCallback? onAddGift;
  final Function(int index)? onPledgeGift;
  final Function(int index)? onGiftTap;
  final Function(int index)? onEditGift;
  final Function(int index)? onDeleteGift;
  final Function(String sortBy)? onSort;

  const GiftListBase({
    super.key,
    required this.title,
    required this.gifts,
    required this.dueDate,
    this.canEdit = false,
    this.canPledge = false,
    this.showAddButton = false,
    this.onAddGift,
    this.onPledgeGift,
    this.onGiftTap,
    this.onEditGift,
    this.onDeleteGift,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseHelper firebaseHelper = FirebaseHelper();

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
                return FutureBuilder<String?>(
                  future: gift.pledgerId != null
                      ? firebaseHelper
                          .getUserFromFirestore(gift.pledgerId!)
                          .then((user) => user?.name)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    final pledgerName = snapshot.data;

                    return GiftCard(
                      gift: {
                        'name': gift.name,
                        'category': gift.category,
                        'price': gift.price,
                        'status': gift.status,
                        'is_published': gift.isPublished,
                        'due_date': dueDate,
                      },
                      pledgerName: pledgerName,
                      onPledge: () => onPledgeGift?.call(index),
                      onTap: () => onGiftTap?.call(index),
                      onDelete: canEdit && gift.status != 'Pledged'
                          ? () => onDeleteGift?.call(index)
                          : null, // Delete only if it's the user's gift and not pledged
                    );
                  },
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
}
