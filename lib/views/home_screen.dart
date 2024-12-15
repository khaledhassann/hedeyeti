import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/LocalUser.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/services/notification_helper.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  late Future<LocalUser> _userFuture;
  final ValueNotifier<Future<List<LocalUser>>?> _friendsFutureNotifier =
      ValueNotifier<Future<List<LocalUser>>?>(null);

  String _searchQuery = "";
  final ValueNotifier<List<Map<String, dynamic>>> _searchResultsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchLoggedInUser();
    // _friendsFuture = _fetchFriends();
    _friendsFutureNotifier.value = _fetchFriends();
    _initializeGiftNotifications();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeGiftNotifications() async {
    final currentUser = await _firebaseHelper.getCurrentUser();
    if (currentUser != null) {
      _firebaseHelper.listenForPledgedGifts(currentUser.id);
    }
  }

  Future<LocalUser> _fetchLoggedInUser() async {
    try {
      final userData = await _firebaseHelper.getCurrentUser();
      return userData ?? LocalUser.fallbackUser();
    } catch (e) {
      print('Error fetching logged-in user: $e');
      return LocalUser.fallbackUser();
    }
  }

  Future<List<LocalUser>> _fetchFriends() async {
    try {
      final currentUser = await _firebaseHelper.getCurrentUser();
      return _firebaseHelper.getFriendsFromFirestore(currentUser!.id);
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  Future<void> _searchUsers(String email) async {
    if (email.isEmpty) {
      _searchResultsNotifier.value = [];
      return;
    }

    try {
      final user = await _firebaseHelper.searchUserByEmailInFirestore(email);
      if (user != null) {
        final currentUser = await _firebaseHelper.getCurrentUser();
        final isFriend =
            await _firebaseHelper.isFriendInFirestore(currentUser!.id, user.id);
        _searchResultsNotifier.value = [
          {'user': user, 'isFriend': isFriend},
        ];
      } else {
        _searchResultsNotifier.value = [];
      }
    } catch (e) {
      print('Error searching users: $e');
      _searchResultsNotifier.value = [];
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  Future<void> _addFriend(String userId, String friendId) async {
    try {
      await _firebaseHelper.addFriendInFirestore(userId, friendId);

      // Refresh the friends list
      _friendsFutureNotifier.value = _fetchFriends();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend added successfully!'),
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

  Future<void> _removeFriend(String friendId) async {
    try {
      final currentUser = await _firebaseHelper.getCurrentUser();
      if (currentUser == null) return;

      await _firebaseHelper.removeFriendInFirestore(currentUser.id, friendId);

      // Refresh the friends list
      _friendsFutureNotifier.value = _fetchFriends();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend removed successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing friend: $e'),
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
                      ? MemoryImage(
                          base64Decode(user.profilePicture),
                        )
                      : const AssetImage('assets/images.png') as ImageProvider,
                ),
              ),
            );
          },
        ),
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
      body: FutureBuilder<LocalUser>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load user data.'));
          }

          final currentUser = snapshot.data!;
          return Stack(
            children: [
              Column(
                children: [
                  _buildSearchBar(),
                  _buildCreateEventButton(context),
                  ValueListenableBuilder<Future<List<LocalUser>>?>(
                    valueListenable: _friendsFutureNotifier,
                    builder: (context, friendsFuture, child) {
                      if (friendsFuture == null) {
                        return const Center(
                            child: Text('No friends to display.'));
                      }
                      return FutureBuilder<List<LocalUser>>(
                        future: friendsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return const Expanded(
                              child: Center(
                                  child: Text('Failed to load friends data.')),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Expanded(
                              child: Center(
                                child: Text(
                                  'No friends yet. Add some to see their events!',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            );
                          }

                          final friends = snapshot.data!;
                          return _buildFriendsList(friends);
                        },
                      );
                    },
                  ),
                ],
              ),
              _buildSearchOverlay(currentUser.id),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _onSearchChanged, // Debounced search logic
            ),
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _searchResultsNotifier,
            builder: (context, searchResults, child) {
              if (searchResults.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchResultsNotifier.value = []; // Clear search results
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String userId) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _searchResultsNotifier,
      builder: (context, searchResults, child) {
        if (searchResults.isEmpty) {
          return const Center(
            child: Text(
              'No results found.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final result = searchResults[index];
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
      },
    );
  }

  // Remaining methods such as `_buildDrawer`, `_buildFriendsList` remain unchanged.
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
              onTap: () async {
                final dataChanged = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );

                // Reload the user data only if changes were made
                if (dataChanged == true) {
                  setState(() {
                    _userFuture = _fetchLoggedInUser();
                  });
                }
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
                        : const AssetImage('assets/images.png')
                            as ImageProvider,
                  ),
                  title: Text(friend.name),
                  subtitle: const Text('Error loading events'),
                  trailing: const Icon(Icons.error, color: Colors.red),
                );
              } else {
                final events = snapshot.data ?? [];
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, EventListPage.routeName,
                        arguments: {
                          'id': friend.id,
                          'name': friend.name,
                          'events': events,
                        });
                  },
                  leading: CircleAvatar(
                    backgroundImage: friend.profilePicture.isNotEmpty
                        ? MemoryImage(base64Decode(friend.profilePicture))
                        : const AssetImage('assets/images.png')
                            as ImageProvider,
                  ),
                  title: Text(friend.name),
                  subtitle: Text(events.isNotEmpty
                      ? 'Upcoming Events: ${events.length}'
                      : 'No Upcoming Events'),
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
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

  Widget _buildSearchOverlay(String userId) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _searchResultsNotifier,
      builder: (context, searchResults, child) {
        if (searchResults.isEmpty) return const SizedBox.shrink();

        return Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _searchResultsNotifier.value = []; // Clear search results
            },
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  final user = result['user'] as LocalUser;
                  final isFriend = result['isFriend'] as bool;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: user.profilePicture.isNotEmpty
                            ? MemoryImage(base64Decode(user.profilePicture))
                            : const AssetImage('assets/images.png')
                                as ImageProvider,
                        radius: 24,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      trailing: isFriend
                          ? OutlinedButton.icon(
                              onPressed: () => _removeFriend(user.id),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _addFriend(userId, user.id),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                              label: const Text(
                                'Add',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
