import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hedeyeti/views/create_edit_event_screen.dart';
import 'package:hedeyeti/views/create_edit_gift_screen.dart';
import 'package:hedeyeti/views/event_list_screen.dart';
import 'package:hedeyeti/views/friend_gift_list_screen.dart';
import 'package:hedeyeti/views/gift_list_screen.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/pledged_gifts_screen.dart';
import 'package:hedeyeti/views/profile_page_screen.dart';
import 'package:hedeyeti/views/register_screen.dart';
import 'package:hedeyeti/views/registration_journey.dart';
import 'package:hedeyeti/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Hedeyeti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        HomePage.routeName: (context) => HomePage(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegistrationJourney.routeName: (context) => RegistrationJourney(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        EventListPage.routeName: (context) => EventListPage(),
        GiftListPage.routeName: (context) => const GiftListPage(),
        ProfilePage.routeName: (context) => ProfilePage(),
        MyPledgedGiftsPage.routeName: (context) => MyPledgedGiftsPage(),
        CreateEditEventPage.routeName: (context) => const CreateEditEventPage(),
        CreateEditGiftPage.routeName: (context) => const CreateEditGiftPage(),
        FriendsGiftListPage.routeName: (context) => const FriendsGiftListPage(),
      },
      initialRoute: SplashScreen.routeName, // Start with Splash Screen
    );
  }
}
