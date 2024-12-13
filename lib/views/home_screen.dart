// HomePage.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/LocalUser.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';
import '../services/database_helper.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  // final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<LocalUser> _userFuture; // Fetch logged-in user's data
  late Future<List<LocalUser>>? _friendsFuture; // Fetch friends' data

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchLoggedInUser();
    _friendsFuture = _fetchFriends();
  }

  /// Fetches the logged-in user's data from FirebaseHelper.
  Future<LocalUser> _fetchLoggedInUser() async {
    try {
      // Use the FirebaseHelper to get the current user
      final userData = await _firebaseHelper.getCurrentUser();

      // If userData is null, provide a default fallback user
      if (userData == null) {
        return LocalUser(
          id: '',
          name: 'Guest',
          email: 'guest@example.com',
          profilePicture: '',
          isMe: true,
          notificationPush: false,
        );
      }

      return userData; // Return the fetched user
    } catch (e) {
      print('Error fetching logged-in user: $e');
      // Provide a fallback user in case of an error
      return LocalUser(
        id: '',
        name: 'Guest',
        email: 'guest@example.com',
        profilePicture: '',
        isMe: true,
        notificationPush: false,
      );
    }
  }

  /// Fetches the list of friends from Firestore.
  Future<List<LocalUser>> _fetchFriends() async {
    try {
      final currentUser = await _firebaseHelper.getCurrentUser();
      return _firebaseHelper.getFriendsFromFirestore(currentUser!.id);
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedeyeti - Home'),
        leading: FutureBuilder<LocalUser>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images.png'),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images.png'),
                ),
              );
            }

            final user = snapshot.data!;
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: user.profilePicture.isNotEmpty
                      ? MemoryImage(base64Decode(user.profilePicture))
                      : const AssetImage('assets/images.png') as ImageProvider,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      drawer: FutureBuilder<LocalUser>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Drawer(
              child: Center(child: Text('Failed to load user data.')),
            );
          }

          final user = snapshot.data!;
          return _buildDrawer(context, user);
        },
      ),
      body: Column(
        children: [
          _buildCreateEventButton(context),
          FutureBuilder<List<LocalUser>>(
            future: _friendsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const Expanded(
                  child: Center(child: Text('Failed to load friends data.')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      'No friends yet. Add some to see their events!',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              final friends = snapshot.data!;
              return _buildFriendsList(friends);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, LocalUser user) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: user.profilePicture.isNotEmpty
                          ? MemoryImage(
                              base64Decode(user.profilePicture),
                            )
                          : const AssetImage('assets/images.png')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  EventListPage.routeName,
                  arguments: {'id': user.id, 'name': user.name, 'events': []},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('My Pledged Gifts'),
              onTap: () {
                Navigator.pushNamed(context, MyPledgedGiftsPage.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Manage profile'),
              onTap: () {
                Navigator.pushNamed(context, ProfilePage.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                _firebaseHelper.logoutUser();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateEventButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, CreateEditEventPage.routeName);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Create Your Own Event/List'),
      ),
    );
  }

  Widget _buildFriendsList(List<LocalUser> friends) {
    return Expanded(
      child: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return FutureBuilder<List<Event>>(
            future: _firebaseHelper.getEventsForUserFromFireStore(friend.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Loading...'),
                  subtitle: Text('Fetching events...'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.profilePicture.isNotEmpty
                        ? MemoryImage(base64Decode(friend.profilePicture))
                        : const AssetImage('assets/default-avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(friend.name),
                  subtitle: const Text('Error loading events'),
                  trailing: const Icon(Icons.error, color: Colors.red),
                );
              } else {
                final events = snapshot.data ?? [];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.profilePicture.isNotEmpty
                        ? MemoryImage(base64Decode(friend.profilePicture))
                        : const AssetImage('assets/default-avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(friend.name),
                  subtitle: Text(events.isNotEmpty
                      ? 'Upcoming Events: ${events.length}'
                      : 'No Upcoming Events'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      EventListPage.routeName,
                      arguments: {
                        'id': friend.id,
                        'name': friend.name,
                        'events': events
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
