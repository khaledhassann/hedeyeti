import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/User.dart';
import 'package:hedeyeti/utils/constants.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';
import '../services/firebase_auth_service.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';
  late final List<Gift> gifts;
  late final List<Event> events;
  late final List<User> exampleUsers;

  HomePage({Key? key}) : super(key: key) {
    // initialization with example lists
    gifts = EXAMPLE_GIFTS;
    events = EXAMPLE_EVENTS;
    exampleUsers = EXAMPLE_USERS;
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
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildCreateEventButton(context),
          _buildFriendsList(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images.png'),
                    ),
                  ),
                  SizedBox(height: 10),
                  FittedBox(
                    child: Text(
                      'Khaled Taha',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      'khaled@email.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: () {
                Navigator.pushNamed(context, EventListPage.routeName,
                    arguments: {
                      'name': 'Khaled Taha',
                      'events': exampleUsers.first.events,
                    });
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
                await authService.logoutUser(); // Log out the user
                Navigator.pushReplacementNamed(
                    context, LoginScreen.routeName); // Navigate to login
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

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: exampleUsers.length,
        itemBuilder: (context, index) {
          final user = exampleUsers[index];
          if (user.isMe) return const SizedBox();
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(user.profilePicture),
            ),
            title: Text(user.name),
            subtitle: Text(
              user.events.isNotEmpty
                  ? 'Upcoming Events: ${user.events.length}'
                  : 'No Upcoming Events',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                EventListPage.routeName,
                arguments: {'name': user.name, 'events': user.events},
              );
            },
          );
        },
      ),
    );
  }
}
