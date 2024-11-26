import 'package:flutter/material.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/create_edit_gift_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/friend_gift_list_screen.dart';
import 'package:hedeyeti/views/gift_list_screen.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, // remove for final screenshots
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => HomePage(),
        '/events': (context) => EventListPage(),
        '/gifts': (context) => GiftListPage(),
        '/profile': (context) => ProfilePage(),
        '/pledged-gifts': (context) => MyPledgedGiftsPage(),
        '/create-edit-event': (context) => const CreateEditEventPage(),
        '/create-edit-gift': (context) => const CreateEditGiftPage(),
        '/friends-gift-list': (context) => const FriendsGiftListPage(),
      },
      initialRoute: '/',
    );
  }
}
