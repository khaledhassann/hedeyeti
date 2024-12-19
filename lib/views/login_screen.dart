import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/registration_journey.dart';
import '../services/database_helper.dart';
import '../services/firebase_helper.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
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
        final userCredential = await _firebaseHelper.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (userCredential != null) {
          final dbHelper = DatabaseHelper();

          // Save user data locally in SQLite
          final rowId = await dbHelper.insertUser(userCredential.toSQLite());
          print(rowId);
          // Query the database for the record with the specific row ID
          final db = await dbHelper.database;
          final result = await db.query(
            'users',
            where: 'rowid = ?',
            whereArgs: [rowId],
            limit: 1,
          );

          if (result.isNotEmpty) {
            print('Record fetched: ${result.first}');
          } else {
            print('No record found with row ID: $rowId');
          }

          // Synchronize data
          await dbHelper.loadEventsAndGiftsForCurrentUser(userCredential.id);

          dbHelper.printDatabasePath();

          // Navigate to the HomePage
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        }
      } on FirebaseAuthException catch (e) {
        _showError(e.code);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again. {$e}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
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
                      key: const ValueKey('Email field'),
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
                      key: const ValueKey('Password field'),
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
                      key: const ValueKey('Login button'),
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
