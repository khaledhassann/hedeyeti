import 'package:flutter/material.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import '../services/database_helper.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, String> user = {}; // User info from the database
  late List<Map<String, dynamic>> events = []; // User's events
  final DatabaseHelper _dbHelper = DatabaseHelper(); // SQLite database helper
  bool emailNotifications = true; // Example notification setting
  bool pushNotifications = false; // Example notification setting

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load user data and events
  }

  /// Loads user data and events from the database
  Future<void> _loadProfileData() async {
    // Fetch user info (assuming single user for simplicity)
    final userData = await _dbHelper.getUser();
    final eventData = await _dbHelper.getEventsForUser(userData.id);

    setState(() {
      user = {
        'name': userData.name,
        'email': userData.email,
      };
      events = eventData;
    });
  }

  /// Updates user info in the database
  Future<void> _editUserInfo() async {
    // Logic to edit user info (example with dialog for input)
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = {
                'id': 1, // Assuming single user with ID = 1
                'name': nameController.text,
                'email': emailController.text,
              };

              await _dbHelper.updateUser(updatedUser);

              setState(() {
                user['name'] = nameController.text;
                user['email'] = emailController.text;
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Toggles notification settings
  void _toggleNotificationSetting(bool value, String type) {
    setState(() {
      if (type == 'email') {
        emailNotifications = value;
      } else if (type == 'push') {
        pushNotifications = value;
      }
    });
    // TODO: Save notification settings to local storage or server
  }

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
              title: Text(user['name'] ?? 'Loading...'),
              subtitle: Text(user['email'] ?? 'Loading...'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editUserInfo, // Edit user info
              ),
            ),
          ),

          // Notification Settings
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  value: emailNotifications,
                  onChanged: (value) =>
                      _toggleNotificationSetting(value, 'email'),
                  title: const Text('Email Notifications'),
                ),
                SwitchListTile(
                  value: pushNotifications,
                  onChanged: (value) =>
                      _toggleNotificationSetting(value, 'push'),
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
                    ).then(
                        (_) => _loadProfileData()); // Reload events on return
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
