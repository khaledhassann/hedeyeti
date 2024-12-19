import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:hedeyeti/views/login_screen.dart';
import 'package:hedeyeti/views/home_screen.dart';
import 'package:hedeyeti/services/firebase_helper.dart';

import '../test_helpers.dart';
import 'login_button_test.mocks.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

@GenerateMocks([FirebaseHelper])
void main() {
  late MockFirebaseHelper mockFirebaseHelper;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock Firebase.initializeApp
    final mockFirebaseApp = MockFirebaseApp();
    when(Firebase.initializeApp()).thenAnswer((_) async => mockFirebaseApp);
  });

  setUp(() {
    mockFirebaseHelper = MockFirebaseHelper();
  });

  tearDown(() {
    reset(mockFirebaseHelper);
  });

  testWidgets('Displays snackbar on invalid email/password',
      (WidgetTester tester) async {
    // Stub FirebaseHelper loginUser to throw a FirebaseAuthException
    when(mockFirebaseHelper.loginUser(any, any)).thenThrow(
      FirebaseAuthException(code: 'wrong-password'),
    );

    // Build LoginScreen with mocked FirebaseHelper
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Enter invalid credentials
    final emailField = find.byKey(const ValueKey('Email field'));
    final passwordField = find.byKey(const ValueKey('Password field'));
    final loginButton = find.byKey(const ValueKey('Login button'));

    await tester.enterText(emailField, 'khaled@email.com');
    await tester.enterText(passwordField, 'wrongpassword');
    await tester.tap(loginButton);

    // Let the UI rebuild
    await tester.pumpAndSettle();

    // Verify snackbar with error message is displayed
    expect(find.text('Invalid password. Please try again.'), findsOneWidget);

    // Verify the login method was called
    verify(mockFirebaseHelper.loginUser('wrong@example.com', 'wrongpassword'))
        .called(1);
  });

  testWidgets('Redirects to home page on successful login',
      (WidgetTester tester) async {
    // Stub FirebaseHelper loginUser to return a valid user
    final mockUser = createTestLocalUser(id: '123', email: 'test@example.com');
    when(mockFirebaseHelper.loginUser(any, any))
        .thenAnswer((_) async => mockUser);

    // Build LoginScreen with mocked FirebaseHelper
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
        routes: {
          HomePage.routeName: (_) => const HomePage(),
        },
      ),
    );

    // Enter valid credentials
    final emailField = find.byKey(const ValueKey('Email field'));
    final passwordField = find.byKey(const ValueKey('Password field'));
    final loginButton = find.byKey(const ValueKey('Login button'));

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);

    // Wait for the loading spinner and navigation
    await tester.pump(); // Show CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify the user is redirected to the home page
    expect(find.text('Hedeyeti - Home'), findsOneWidget);

    // Verify the login method was called
    verify(mockFirebaseHelper.loginUser('test@example.com', 'password123'))
        .called(1);
  });
}
