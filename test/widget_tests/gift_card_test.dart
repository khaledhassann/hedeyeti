import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hedeyeti/widgets/gift_card.dart';

class MockCallback extends Mock {
  void call(); // Matches the signature of VoidCallback
}

void main() {
  group('GiftCard Widget Tests', () {
    late MockCallback mockOnPledge;
    late MockCallback mockOnTap;
    late MockCallback mockOnDelete;

    setUp(() {
      mockOnPledge = MockCallback();
      mockOnTap = MockCallback();
      mockOnDelete = MockCallback();
    });

    testWidgets('Displays gift details correctly', (WidgetTester tester) async {
      final gift = {
        'name': 'Test Gift',
        'category': 'Electronics',
        'price': 100.0,
        'due_date': '2024-01-01',
        'status': 'Available',
        'is_published': false,
      };

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiftCard(
              gift: gift,
              onPledge: mockOnPledge,
              onTap: mockOnTap,
              onDelete: mockOnDelete,
            ),
          ),
        ),
      );

      // Verify details are displayed correctly
      expect(find.text('Test Gift'), findsOneWidget);
      expect(find.text('Category: Electronics'), findsOneWidget);
      expect(find.text('Price: \$100.0'), findsOneWidget);
      expect(find.text('Due date: 2024-01-01'), findsOneWidget);
      expect(
          find.byIcon(Icons.cloud_off_outlined), findsOneWidget); // Unpublished
    });

    testWidgets('Calls onPledge when Pledge button is pressed',
        (WidgetTester tester) async {
      final gift = {
        'name': 'Test Gift',
        'category': 'Electronics',
        'price': 100.0,
        'due_date': '2024-01-01',
        'status': 'Available',
      };

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiftCard(
              gift: gift,
              onPledge: mockOnPledge,
              onTap: mockOnTap,
            ),
          ),
        ),
      );

      // Tap the Pledge button
      final pledgeButton = find.text('Pledge');
      expect(pledgeButton, findsOneWidget);
      await tester.tap(pledgeButton);

      // Verify onPledge callback is called
      verify(mockOnPledge()).called(1);
    });

    testWidgets('Calls onDelete when Delete button is pressed',
        (WidgetTester tester) async {
      final gift = {
        'name': 'Test Gift',
        'category': 'Electronics',
        'price': 100.0,
        'due_date': '2024-01-01',
        'status': 'Available',
      };

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiftCard(
              gift: gift,
              onPledge: mockOnPledge,
              onTap: mockOnTap,
              onDelete: mockOnDelete,
            ),
          ),
        ),
      );

      // Tap the Delete button
      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);

      // Verify onDelete callback is called
      verify(mockOnDelete()).called(1);
    });

    testWidgets('Calls onTap when card is tapped', (WidgetTester tester) async {
      final gift = {
        'name': 'Test Gift',
        'category': 'Electronics',
        'price': 100.0,
        'due_date': '2024-01-01',
        'status': 'Available',
      };

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiftCard(
              gift: gift,
              onPledge: mockOnPledge,
              onTap: mockOnTap,
            ),
          ),
        ),
      );

      // Tap the card
      final card = find.byType(ListTile);
      expect(card, findsOneWidget);
      await tester.tap(card);

      // Verify onTap callback is called
      verify(mockOnTap()).called(1);
    });

    testWidgets('Displays correct icons based on gift status',
        (WidgetTester tester) async {
      final giftPledged = {
        'name': 'Pledged Gift',
        'category': 'Books',
        'price': 50.0,
        'due_date': '2024-02-01',
        'status': 'Pledged',
        'is_published': true,
      };

      // Build the widget with a pledged gift
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GiftCard(
              gift: giftPledged,
              onPledge: mockOnPledge,
              onTap: mockOnTap,
            ),
          ),
        ),
      );

      // Verify correct icons are displayed
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Pledged icon
      expect(
          find.byIcon(Icons.cloud_done_outlined), findsOneWidget); // Published
    });
  });
}
