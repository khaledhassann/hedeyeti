import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  Map<String, String> user = {}; // User info from Firebase
  List<Event> events = []; // User's events
  bool emailNotifications = true; // Example notification setting
  bool pushNotifications = false; // Example notification setting

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load user data and events
  }

  /// Loads user data and events from Firebase
  Future<void> _loadProfileData() async {
    final currentUser = await _firebaseHelper.getCurrentUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading profile. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userEvents =
        await _firebaseHelper.getEventsForUserFromFireStore(currentUser.id);

    setState(() {
      user = {
        'name': currentUser.name,
        'email': currentUser.email,
      };
      events = userEvents ?? [];
      emailNotifications = currentUser.notificationPush; // Example setting
      pushNotifications = currentUser.notificationPush; // Example setting
    });
  }

  /// Updates user info in Firebase
  Future<void> _editUserInfo() async {
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
              final updatedName = nameController.text;
              final updatedEmail = emailController.text;

              // Update in Firebase
              final currentUser = await _firebaseHelper.getCurrentUser();
              if (currentUser != null) {
                await _firebaseHelper.updateUserInFirestore(
                  userId: currentUser.id,
                  name: updatedName,
                  email: updatedEmail,
                );
                setState(() {
                  user['name'] = updatedName;
                  user['email'] = updatedEmail;
                });
              }

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
  void _toggleNotificationSetting(bool value) async {
    setState(() {
      pushNotifications = value;
    });

    // Update in Firebase
    final currentUser = await _firebaseHelper.getCurrentUser();
    if (currentUser != null) {
      await _firebaseHelper.updateUserInFirestore(
        userId: currentUser.id,
        notificationPush: value,
      );
    }
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
                  value: pushNotifications,
                  onChanged: (value) => _toggleNotificationSetting(value),
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
                title: Text(event.name),
                subtitle: Text('Date: ${event.formattedDate}'),
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
