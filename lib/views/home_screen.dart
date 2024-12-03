// HomePage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure Firestore is imported
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/User.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/database_helper.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<User> _userFuture; // Fetch logged-in user's data
  late Future<List<User>> _friendsFuture; // Fetch friends' data

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchLoggedInUser();
    _friendsFuture = _fetchFriends();
  }

  /// Fetches the logged-in user's data from the local SQLite database.
  Future<User> _fetchLoggedInUser() async {
    try {
      final userData =
          await _dbHelper.getUser(); // Now returns a User with String ID
      return userData;
    } catch (e) {
      print('Error fetching logged-in user: $e');
      rethrow;
    }
  }

  /// Fetches the list of friends from Firestore based on friend IDs stored in SQLite.
  Future<List<User>> _fetchFriends() async {
    try {
      // Fetch the logged-in user
      final currentUser = await _dbHelper.getUser();
      final userId = currentUser.id; // Now a String

      // Fetch friend IDs (List<String>)
      final friendIds = await _dbHelper.getFriends(userId);
      final firestore = FirebaseFirestore.instance;

      // Fetch all friends' data in parallel
      final futures = friendIds.map((firestoreId) async {
        try {
          final doc =
              await firestore.collection('users').doc(firestoreId).get();
          if (doc.exists && doc.data() != null) {
            return User.fromFirestore(doc.data()!, doc.id);
          } else {
            print('Friend with id $firestoreId does not exist in Firestore.');
            return null;
          }
        } catch (e) {
          print('Error fetching friend with id $firestoreId: $e');
          return null;
        }
      }).toList();

      final friendsData = await Future.wait(futures);
      return friendsData.whereType<User>().toList();
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
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images.png'),
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
      drawer: FutureBuilder<User>(
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
          FutureBuilder<List<User>>(
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

  /// Builds the navigation drawer with user information and navigation options.
  Widget _buildDrawer(BuildContext context, User user) {
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
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.profilePicture.isNotEmpty
                        ? NetworkImage(user.profilePicture)
                        : const AssetImage('assets/default-avatar.png')
                            as ImageProvider,
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
                  arguments: {
                    'name': user.name,
                    'events': user.events,
                  },
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
                final authService = FirebaseAuthService();
                await authService.logoutUser();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the button to navigate to the event creation/editing screen.
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

  /// Builds the list of friends fetched from Firestore.
  Widget _buildFriendsList(List<User> friends) {
    return Expanded(
      child: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: friend.profilePicture.isNotEmpty
                  ? NetworkImage(friend.profilePicture)
                  : const AssetImage('assets/default-avatar.png')
                      as ImageProvider,
            ),
            title: Text(friend.name),
            subtitle: Text(
              friend.events.isNotEmpty
                  ? 'Upcoming Events: ${friend.events.length}'
                  : 'No Upcoming Events',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                EventListPage.routeName,
                arguments: {'name': friend.name, 'events': friend.events},
              );
            },
          );
        },
      ),
    );
  }
}
