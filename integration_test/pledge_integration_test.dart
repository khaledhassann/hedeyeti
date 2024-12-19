import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedeyeti/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test: Login and Pledge a Gift', () {
    testWidgets('Complete flow: Login -> Friend -> Event -> Pledge Gift',
        (WidgetTester tester) async {
      print('Starting the app...');
      app.main();
      await tester.pumpAndSettle();
      print('App launched.');

      // Check for splash screen and wait for it to disappear
      print('Checking for splash screen...');
      final splashScreenFinder =
          find.byKey(const ValueKey('Splash Screen Widget'));
      if (splashScreenFinder.evaluate().isNotEmpty) {
        print('Splash screen found. Waiting for transition...');
        await tester.pumpAndSettle();
      } else {
        print('Splash screen not found. Checking current widgets...');
      }

      // Ensure navigation to the login screen
      print('Checking for login screen...');
      final emailField = find.byKey(const ValueKey('Email field'));
      if (emailField.evaluate().isEmpty) {
        print('Login screen not yet loaded. Waiting more...');
        await tester.pumpAndSettle();
      }
      expect(emailField, findsOneWidget);
      print('Login screen verified.');

      // Enter credentials and login
      print('Entering login credentials...');
      final passwordField = find.byKey(const ValueKey('Password field'));
      final loginButton = find.byKey(const ValueKey('Login button'));

      await tester.enterText(emailField, 'khaled@email.com');
      await tester.enterText(passwordField, 'pass1234');
      print('Login credentials entered.');
      await tester.tap(loginButton);
      print('Login button tapped.');
      await tester.pumpAndSettle();

      // Verify navigation to the Home Page
      print('Checking if navigated to home page...');
      expect(find.text('Hedeyeti - Home'), findsOneWidget);
      print('Navigation to home page verified.');

      // Navigate to Friend List and choose the first friend
      print('Checking for friend list...');
      final firstFriend = find.byKey(const ValueKey('Friend tile')).first;
      expect(firstFriend, findsOneWidget);
      print('Friend tile found. Tapping...');
      await tester.tap(firstFriend);
      await tester.pumpAndSettle();

      // Wait explicitly for event list to load
      print('Waiting for event list to load...');
      await Future.delayed(
          const Duration(seconds: 2)); // Adjust duration if necessary
      await tester.pumpAndSettle();

      // Navigate to the Event List and choose the first event
      print('Checking for event list...');
      final firstEvent = find.byKey(const ValueKey('Event card')).first;
      if (firstEvent.evaluate().isEmpty) {
        print('No event cards found. Current widget tree:');
        debugPrint(
            tester.allWidgets.map((widget) => widget.toString()).join('\n'));
      }
      expect(firstEvent, findsWidgets);
      print('Event card found. Tapping...');
      await tester.tap(firstEvent);
      await tester.pumpAndSettle();
      print('Navigated to the event\'s gift list.');

      // Wait explicitly for event list to load
      print('Waiting for gift list to load...');
      await Future.delayed(
          const Duration(seconds: 2)); // Adjust duration if necessary
      await tester.pumpAndSettle();

      // Tap the "Pledge" button for the first gift directly
      print('Checking for pledge button...');
      final pledgeButton = find.widgetWithText(TextButton, 'Pledge').first;
      if (pledgeButton.evaluate().isEmpty) {
        print('No pledge buttons found. Current widget tree:');
        debugPrint(
            tester.allWidgets.map((widget) => widget.toString()).join('\n'));
      }
      expect(pledgeButton, findsOneWidget);
      print('Pledge button found. Tapping...');
      await tester.tap(pledgeButton);
      await tester.pumpAndSettle();
      print('Pledge button tapped.');

      // Verify that the gift's status changes to "Pledged"
      print('Checking if gift status updated to Pledged...');
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      print('Gift status updated to Pledged.');
    });
  });
}
