import 'package:flutter/material.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';

class ProfilePage extends StatelessWidget {
  static const routeName = '/profile';
  final Map<String, String> user = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
  };

  final List<Map<String, dynamic>> events = [
    {'name': 'Birthday Party', 'date': '2024-12-10', 'category': 'Birthday'},
    {'name': 'Wedding', 'date': '2024-11-30', 'category': 'Wedding'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Info
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text(user['name']!),
              subtitle: Text(user['email']!),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement user info editing
                },
              ),
            ),
          ),

          // Notification Settings
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                  title: const Text('Email Notifications'),
                ),
                SwitchListTile(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                  title: const Text('Push Notifications'),
                ),
              ],
            ),
          ),

          // My Events
          const Text(
            'My Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...events.map((event) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(event['name']),
                subtitle: Text('Date: ${event['date']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      CreateEditEventPage.routeName,
                      arguments: event, // Pass selected event data
                    );
                  },
                ),
              ),
            );
          }).toList(),

          // My Pledged Gifts Button
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, MyPledgedGiftsPage.routeName);
            },
            child: const Text('View My Pledged Gifts'),
          ),
        ],
      ),
    );
  }
}
