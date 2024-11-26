import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Khaled Taha',
      'profilePicture': 'assets/images.png',
      'upcomingEvents': 2,
      'events': [
        {
          'name': 'Birthday Party',
          'date': '2024-12-10',
          'category': 'Birthday',
          'gifts': [
            {
              'name': 'Smartphone',
              'category': 'Electronics',
              'price': 799.99,
              'status': 'Available'
            },
            {
              'name': 'Book: Flutter for Beginners',
              'category': 'Books',
              'price': 19.99,
              'status': 'Available'
            },
          ],
        },
        {
          'name': 'Wedding',
          'date': '2024-11-30',
          'category': 'Wedding',
          'gifts': [
            {
              'name': 'Blender',
              'category': 'Home Appliances',
              'price': 149.99,
              'status': 'Available'
            },
          ],
        },
      ],
    },
    {
      'name': 'John Doe',
      'profilePicture': 'assets/man02.png',
      'upcomingEvents': 2,
      'events': [
        {
          'name': 'Birthday Party',
          'date': '2024-12-10',
          'category': 'Birthday',
          'gifts': [
            {
              'name': 'Smartphone',
              'category': 'Electronics',
              'price': 799.99,
              'status': 'Available'
            },
            {
              'name': 'Book: Flutter for Beginners',
              'category': 'Books',
              'price': 19.99,
              'status': 'Available'
            },
          ],
        },
        {
          'name': 'Wedding',
          'date': '2024-11-30',
          'category': 'Wedding',
          'gifts': [
            {
              'name': 'Blender',
              'category': 'Home Appliances',
              'price': 149.99,
              'status': 'Available'
            },
          ],
        },
      ],
    },
    {
      'name': 'Jane Smith',
      'profilePicture': 'assets/girl01.png',
      'upcomingEvents': 0,
      'events': [],
    },
    {
      'name': 'Emily Johnson',
      'profilePicture': 'assets/man01.png',
      'upcomingEvents': 1,
      'events': [
        {
          'name': 'Graduation Party',
          'date': '2024-09-15',
          'category': 'Graduation',
          'gifts': [
            {
              'name': 'Laptop',
              'category': 'Electronics',
              'price': 999.99,
              'status': 'Available'
            },
          ],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedeyeti - Home'),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer(); // Open drawer on avatar tap
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      AssetImage('assets/images.png'), // Placeholder
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
      drawer: Drawer(
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
                    'name': 'Khaled Taha', // Placeholder for user name
                    'events': friends.firstWhere(
                        (friend) => friend['name'] == 'Khaled Taha')['events'],
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
                title: const Text('Settings'),
                onTap: () {
                  // TODO: Navigate to settings page
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
      ),
      body: Column(
        children: [
          // Button to create a new event or list
          Padding(
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
          ),
          // Friends List
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                if (index == 0) return Center();
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(friend['profilePicture']),
                  ),
                  title: Text(friend['name']),
                  subtitle: Text(
                    friend['upcomingEvents'] > 0
                        ? 'Upcoming Events: ${friend['upcomingEvents']}'
                        : 'No Upcoming Events',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to Event List Page with friend's data
                    Navigator.pushNamed(
                      context,
                      '/events',
                      arguments: friend, // Pass the friend's data
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
