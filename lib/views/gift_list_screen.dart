import 'package:flutter/material.dart';
import '../widgets/gift_list_base.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({Key? key}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late List<Map<String, dynamic>> gifts;

  @override
  void initState() {
    super.initState();
    gifts = [
      // Example data
      {
        'name': 'Smartphone',
        'category': 'Electronics',
        'price': 700.0,
        'status': 'Available'
      },
      {'name': 'Book', 'category': 'Books', 'price': 25.0, 'status': 'Pledged'},
    ];
  }

  void _addGift() {
    // Navigate to add gift screen
  }

  void _editGift(int index) {
    // Navigate to edit gift screen with gift data
  }

  void _deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  void _sortGifts(String sortBy) {
    setState(() {
      if (sortBy == 'Name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (sortBy == 'Category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (sortBy == 'Status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GiftListBase(
      title: 'Event Gifts',
      gifts: gifts,
      canEdit: true,
      showAddButton: true,
      onAddGift: _addGift,
      onEditGift: _editGift,
      onDeleteGift: _deleteGift,
      onSort: _sortGifts,
    );
  }
}
