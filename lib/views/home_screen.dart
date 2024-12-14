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

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  late Future<LocalUser> _userFuture; // Fetch logged-in user's data
  late Future<List<LocalUser>>? _friendsFuture; // Fetch friends' data

  String _searchQuery = "";
  List<Map<String, dynamic>> _searchResults = []; // User + Friendship status

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchLoggedInUser();
    _friendsFuture = _fetchFriends();
  }

  /// Fetches the logged-in user's data from FirebaseHelper.
  Future<LocalUser> _fetchLoggedInUser() async {
    try {
      final userData = await _firebaseHelper.getCurrentUser();
      return userData ?? LocalUser.fallbackUser();
    } catch (e) {
      print('Error fetching logged-in user: $e');
      return LocalUser.fallbackUser();
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

  /// Search users by email and check if they are friends.
  Future<void> _searchUsers(String email) async {
    try {
      final user = await _firebaseHelper.searchUserByEmailInFirestore(email);
      if (user != null) {
        final currentUser = await _firebaseHelper.getCurrentUser();
        final isFriend =
            await _firebaseHelper.isFriendInFirestore(currentUser!.id, user.id);
        setState(() {
          _searchResults = [
            {'user': user, 'isFriend': isFriend},
          ];
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  /// Add friend functionality.
  Future<void> _addFriend(String userId, String friendId) async {
    try {
      await _firebaseHelper.addFriendInFirestore(userId, friendId);
      setState(() {
        _searchResults = _searchResults.map((result) {
          if (result['user'].id == friendId) {
            result['isFriend'] = true;
          }
          return result;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Friend added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding friend: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
              _showSearchDialog();
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Users'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Enter email...'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchUsers(_searchQuery);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(String userId) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final user = result['user'] as LocalUser;
        final isFriend = result['isFriend'] as bool;

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: isFriend
              ? const Text(
                  'Already friends',
                  style: TextStyle(color: Colors.green),
                )
              : ElevatedButton.icon(
                  onPressed: () => _addFriend(userId, user.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Friend'),
                ),
        );
      },
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
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        EventListPage.routeName,
                        arguments: {
                          'id': friend.id,
                          'name': friend.name,
                          'events': events,
                        },
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
