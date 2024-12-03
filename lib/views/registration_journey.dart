import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';

class RegistrationJourney extends StatefulWidget {
  static const routeName = '/registration-journey';

  const RegistrationJourney({super.key});

  @override
  State<RegistrationJourney> createState() => _RegistrationJourneyState();
}

class _RegistrationJourneyState extends State<RegistrationJourney> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId; // To store the registered user's ID

  void _nextStep() async {
    if (_currentStep == 0 && _formKeyStep1.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Auth: Register user with email and password
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        _userId = userCredential.user!.uid;

        // Save initial user data to Firestore
        await _firestore.collection('users').doc(_userId).set({
          'name': '',
          'email': _emailController.text.trim(),
          'preferences': {
            'notificationEmail': true,
            'notificationPush': true,
          },
        });

        // Proceed to the next step
        setState(() {
          _isLoading = false;
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else if (_currentStep == 1 && _formKeyStep2.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update additional user details in Firestore
      await _firestore.collection('users').doc(_userId).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // Navigate to home or the next screen
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete registration.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Journey'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: Email and Password
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKeyStep1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/hedeyeti-logo.png',
                      height: screenHeight * 0.2,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 150),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
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
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next'),
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, LoginScreen.routeName);
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Step 2: Additional Information
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKeyStep2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/hedeyeti-logo.png',
                      height: screenHeight * 0.2,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 150),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Step 3: Confirmation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/hedeyeti-logo.png',
                  height: screenHeight * 0.2,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 150),
                ),
                const SizedBox(height: 24),
                Text(
                  'Review Your Information:',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Name: ${_nameController.text}',
                    textAlign: TextAlign.center),
                Text('Email: ${_emailController.text}',
                    textAlign: TextAlign.center),
                Text('Phone: ${_phoneController.text}',
                    textAlign: TextAlign.center),
                Text('Address: ${_addressController.text}',
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _completeRegistration,
                  child: const Text('Complete Registration'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
