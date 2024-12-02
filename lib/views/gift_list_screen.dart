import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../widgets/gift_list_base.dart';

class GiftListPage extends StatefulWidget {
  static const routeName = '/gifts';
  const GiftListPage({Key? key}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late List<Gift> gifts;

  @override
  void initState() {
    super.initState();
    gifts = [
      Gift(
        id: null, // New gifts initially have no ID
        name: "Smartphone",
        category: 'Electronics',
        price: 799.99,
        status: 'Available',
        description: "A high-end smartphone with great features.",
        eventId: 1, // Replace with the actual event ID
      ),
      Gift(
        id: null,
        name: 'Blender',
        category: 'Home Appliances',
        price: 149.99,
        status: 'Available',
        description: "A durable blender for your kitchen.",
        eventId: 1,
      ),
      Gift(
        id: null,
        name: 'Laptop',
        category: 'Electronics',
        price: 1499.75,
        status: 'Pledged',
        description: "A powerful laptop for work and play.",
        eventId: 1,
      ),
      Gift(
        id: null,
        name: 'Flutter for Beginners',
        category: 'Books',
        price: 24.99,
        status: 'Available',
        description: "An excellent book for learning Flutter.",
        eventId: 1,
      ),
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
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortBy == 'Category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortBy == 'Status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
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
