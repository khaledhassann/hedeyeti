import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/registration_journey.dart';
import '../services/database_helper.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = FirebaseAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  /// Handles the login process and synchronization of user data
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Log the user in with FirebaseAuth
        final userCredential = await _authService.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        final userId = userCredential!.uid;

        // Fetch and sync user data, events, and gifts
        await _syncUserData(userId);

        // Navigate to the HomePage
        Navigator.pushReplacementNamed(context, HomePage.routeName);
      } on FirebaseAuthException catch (e) {
        _showError(e.code);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Synchronizes user data, events, and gifts from Firestore to SQLite
  Future<void> _syncUserData(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final dbHelper = DatabaseHelper();

    // Fetch user data from Firestore
    final userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception("User data not found in Firestore.");
    final userData = userDoc.data()!;

    // Save user data locally in SQLite
    await dbHelper.updateUser({
      'id': int.parse(userId), // Assuming userId is an integer
      'name': userData['name'],
      'email': userData['email'],
      'preferences': userData['preferences'],
    });

    // Fetch and save user's events
    final eventsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();

    for (final eventDoc in eventsSnapshot.docs) {
      final eventId = int.parse(eventDoc.id);
      final eventData = eventDoc.data();

      // Save event to SQLite
      await dbHelper.insertEvent({
        'id': eventId,
        'name': eventData['name'],
        'date': eventData['date'],
        'location': eventData['location'],
        'description': eventData['description'],
        'category': eventData['category'],
        'user_id': int.parse(userId),
      });

      // Fetch and save gifts for the event
      final giftsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventDoc.id)
          .collection('gifts')
          .get();

      for (final giftDoc in giftsSnapshot.docs) {
        final giftId = int.parse(giftDoc.id);
        final giftData = giftDoc.data();

        // Save gift to SQLite
        await dbHelper.insertGift({
          'id': giftId,
          'name': giftData['name'],
          'description': giftData['description'],
          'price': giftData['price'],
          'category': giftData['category'],
          'status': giftData['status'],
          'event_id': eventId,
        });
      }
    }
  }

  /// Displays appropriate error messages for login failures
  void _showError(String code) {
    String errorMessage;
    switch (code) {
      case 'user-not-found':
        errorMessage = 'No user found for this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Invalid password. Please try again.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      default:
        errorMessage = 'An unknown error occurred. Please try again.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 24, color: Colors.deepPurple),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo and Name
              Image.asset(
                'assets/hedeyeti-logo.png', // Add a logo image asset
                height: 150,
              ),
              const SizedBox(height: 32),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
              const SizedBox(height: 16),

              // Registration Option
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, RegistrationJourney.routeName);
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
