import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedeyeti/services/database_helper.dart';
import 'package:hedeyeti/services/image_helper.dart';
import 'package:image_picker/image_picker.dart'; // Add this package
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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ImagePicker _imagePicker = ImagePicker(); // Add ImagePicker instance
  Map<String, String> user = {}; // User info from Firebase
  List<Event> events = []; // User's events
  String profilePicture = ''; // Base64 string for profile picture
  bool pushNotifications = false; // Example notification setting
  bool _dataChanged = false; // Track changes

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
      profilePicture = currentUser.profilePicture; // Load profile picture
      events = userEvents ?? [];
      pushNotifications = currentUser.notificationPush; // Example setting
    });
  }

  /// Updates profile picture in Firestore
  Future<void> _updateProfilePicture(String base64Image) async {
    final currentUser = await _firebaseHelper.getCurrentUser();
    if (currentUser == null) return;

    await _firebaseHelper.updateUserInFirestore(
      userId: currentUser.id,
      profilePicture: base64Image,
    );
    await _databaseHelper.updateUser(
      currentUser.copyWith(profilePicture: base64Image).toSQLite(),
    );

    setState(() {
      profilePicture = base64Image;
      _dataChanged = true; // Mark data as changed
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Picks an image from gallery or camera
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final base64Image = await ImageHelper.selectImage();
                _updateProfilePicture(base64Image ?? "");
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final base64Image = await ImageHelper.captureImage(context);
                _updateProfilePicture(base64Image ?? "");
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles notification settings
  void _toggleNotificationSetting(bool value) async {
    setState(() {
      pushNotifications = value;
    });

    final currentUser = await _firebaseHelper.getCurrentUser();
    if (currentUser != null) {
      await _firebaseHelper.updateUserInFirestore(
        userId: currentUser.id,
        notificationPush: value,
      );
      await _databaseHelper.updateUser(
        currentUser.copyWith(notificationPush: value).toSQLite(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, _dataChanged); // Pass the flag on back navigation
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dataChanged); // Return if data changed
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profilePicture.isNotEmpty
                        ? MemoryImage(base64Decode(profilePicture))
                        : const AssetImage('assets/images.png')
                            as ImageProvider,
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Info
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: Text('Username'),
                subtitle: Text(user['name'] ?? 'Loading...'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editUserInfo(),
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
                        arguments: event,
                      ).then((_) => _loadProfileData());
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
      ),
    );
  }

  Future<void> _editUserInfo() async {
    final nameController = TextEditingController(text: user['name']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'User name'),
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

              // Update in Firebase
              final currentUser = await _firebaseHelper.getCurrentUser();
              if (currentUser != null) {
                await _firebaseHelper.updateUserInFirestore(
                  userId: currentUser.id,
                  name: updatedName,
                );
                await _databaseHelper.updateUser(
                  currentUser.copyWith(name: updatedName).toSQLite(),
                );
                setState(() {
                  user['name'] = updatedName;
                  _dataChanged = true; // Mark data as changed
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
}
