import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/services/image_helper.dart';

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

  int _currentStep = 0;
  bool _isLoading = false;
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  String? _profilePictureBase64; // Store the profile picture as a Base64 string

  late String _userId; // To store the registered user's ID

  void _nextStep() async {
    if (_currentStep == 0 && _formKeyStep1.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Register user with Firebase Helper
        await _firebaseHelper.registerUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final currentUser = await _firebaseHelper.getCurrentUser();
        if (currentUser != null) _userId = currentUser.id;

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
      await _firebaseHelper.updateUserInFirestore(
        userId: _userId,
        name: _nameController.text.trim(),
        profilePicture: _profilePictureBase64,
      );

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

  Future<void> _pickImage() async {
    final pickedFilePath = await ImageHelper.selectImage();

    if (pickedFilePath != null) {
      final bytes = await File(pickedFilePath).readAsBytes();
      setState(() {
        _profilePictureBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFilePath = await ImageHelper.captureImage(context);

    if (pickedFilePath != null) {
      final bytes = await File(pickedFilePath).readAsBytes();
      setState(() {
        _profilePictureBase64 = base64Encode(bytes);
      });
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

          // Step 2: Additional Information and Profile Picture
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
                    const SizedBox(height: 24),

                    // Profile Picture Upload
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Upload Photo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                      ],
                    ),
                    if (_profilePictureBase64 != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Image.memory(
                          base64Decode(_profilePictureBase64!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
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
