import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  final List<Map<String, dynamic>> gifts = [
    {
      'name': 'Smartphone',
      'category': 'Electronics',
      'price': 700.0,
      'status': 'Available',
    },
    {
      'name': 'Book: Flutter for Beginners',
      'category': 'Books',
      'price': 25.0,
      'status': 'Pledged',
    },
    {
      'name': 'Headphones',
      'category': 'Accessories',
      'price': 50.0,
      'status': 'Available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement sorting logic
            },
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
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: gift['status'] == 'Pledged'
                    ? Colors.red[100]
                    : Colors.green[100],
                child: Icon(
                  gift['status'] == 'Pledged'
                      ? Icons.check
                      : Icons.card_giftcard,
                  color:
                      gift['status'] == 'Pledged' ? Colors.red : Colors.green,
                ),
              ),
              title: Text(gift['name']),
              subtitle: Text(
                '${gift['category']} - \$${gift['price']}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    // TODO: Navigate to Edit Gift Page
                    Navigator.pushNamed(
                      context,
                      '/create-edit-gift',
                      arguments: gift, // Pass the gift's data for editing
                    );
                  } else if (value == 'Delete') {
                    // TODO: Implement Delete Functionality
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
              ),
              onTap: () {
                // TODO: Navigate to Gift Details Page
                Navigator.pushNamed(context, '/gift-details');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create-edit-gift', // Named route for the page
          );
        },
        tooltip: 'Add Gift',
        child: const Icon(Icons.add),
      ),
    );
  }
}
