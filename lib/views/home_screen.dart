import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Event.dart';
import 'package:hedeyeti/models/Gift.dart';
import 'package:hedeyeti/models/User.dart';

class HomePage extends StatelessWidget {
  late final List<Gift> gifts;
  late final List<Event> events;
  late final List<User> exampleUsers;

  HomePage({Key? key}) : super(key: key) {
    // Initialize gifts
    gifts = [
      Gift(
          name: "Smartphone",
          category: 'Electronics',
          price: 799.99,
          status: 'Available'),
      Gift(
          name: 'Blender',
          category: 'Home Appliances',
          price: 149.99,
          status: 'Available'),
      Gift(
          name: 'Laptop',
          category: 'Electronics',
          price: 1499.75,
          status: 'Pledged'),
      Gift(
          name: 'Flutter for Beginners',
          category: 'Books',
          price: 24.99,
          status: 'Available'),
    ];

    // Initialize events
    events = [
      Event(
          name: 'Birthday party',
          date: DateTime(2024, 12, 15),
          category: 'Birthday',
          gifts: gifts),
      Event(
          name: 'Wedding',
          date: DateTime(2025, 9, 30),
          category: 'Wedding',
          gifts: gifts),
      Event(
          name: 'Graduation party',
          date: DateTime(2025, 7, 1),
          category: 'Graduation',
          gifts: gifts),
    ];

    // Initialize users
    exampleUsers = [
      User(
          name: 'Khaled Taha',
          email: 'khaled@email.com',
          profilePicture: 'assets/images.png',
          isMe: true,
          events: events),
      User(
          name: 'John Doe',
          email: 'john.doe@email.com',
          profilePicture: 'assets/man02.png',
          isMe: false,
          events: events),
      User(
          name: 'Jane Smith',
          email: 'jane.smith@email.com',
          profilePicture: 'assets/girl01.png',
          isMe: false,
          events: []),
      User(
          name: 'Pablo Escobar',
          email: 'pablo.escobar@email.com',
          profilePicture: 'assets/man01.png',
          isMe: false,
          events: events),
    ];
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
                Navigator.pushNamed(context, '/events', arguments: {
                  'name': 'Khaled Taha',
                  'events': exampleUsers.first.events,
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('My Pledged Gifts'),
              onTap: () {
                Navigator.pushNamed(context, '/pledged-gifts');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Manage profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout functionality
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
          Navigator.pushNamed(context, '/create-edit-event');
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
                '/events',
                arguments: {'name': user.name, 'events': user.events},
              );
            },
          );
        },
      ),
    );
  }
}
