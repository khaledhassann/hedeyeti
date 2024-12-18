import 'package:flutter_test/flutter_test.dart';
import 'package:hedeyeti/models/Gift.dart';

void main() {
  group('Gift Model Tests', () {
    final sampleGift = Gift(
      id: '1',
      name: 'Test Gift',
      description: 'A sample gift for testing',
      category: 'Electronics',
      price: 99.99,
      status: 'Available',
      eventId: 'event1',
      pledgerId: 'user123',
      isPublished: true,
    );

    test('Serialization to SQLite Map', () {
      final expectedMap = {
        'id': '1',
        'name': 'Test Gift',
        'description': 'A sample gift for testing',
        'category': 'Electronics',
        'price': 99.99,
        'status': 'Available',
        'event_id': 'event1',
        'pledger_id': 'user123',
        'is_published': 1,
      };

      expect(sampleGift.toSQLite(), equals(expectedMap));
    });

    test('Serialization to Firestore Map', () {
      final expectedMap = {
        'name': 'Test Gift',
        'description': 'A sample gift for testing',
        'category': 'Electronics',
        'price': 99.99,
        'status': 'Available',
        'event_id': 'event1',
        'pledger_id': 'user123',
      };

      expect(sampleGift.toFirestore(), equals(expectedMap));
    });

    test('Deserialization from SQLite Map', () {
      final sqliteMap = {
        'id': '1',
        'name': 'Test Gift',
        'description': 'A sample gift for testing',
        'category': 'Electronics',
        'price': 99.99,
        'status': 'Available',
        'event_id': 'event1',
        'pledger_id': 'user123',
        'is_published': 1,
      };

      final gift = Gift.fromMap(sqliteMap);

      expect(gift.id, equals('1'));
      expect(gift.name, equals('Test Gift'));
      expect(gift.description, equals('A sample gift for testing'));
      expect(gift.category, equals('Electronics'));
      expect(gift.price, equals(99.99));
      expect(gift.status, equals('Available'));
      expect(gift.eventId, equals('event1'));
      expect(gift.pledgerId, equals('user123'));
      expect(gift.isPublished, equals(true));
    });

    test('Deserialization from Firestore Map', () {
      final firestoreMap = {
        'name': 'Test Gift',
        'description': 'A sample gift for testing',
        'category': 'Electronics',
        'price': 99.99,
        'status': 'Available',
        'event_id': 'event1',
        'pledger_id': 'user123',
      };

      final gift = Gift.fromFirestore(firestoreMap, '1');

      expect(gift.id, equals('1'));
      expect(gift.name, equals('Test Gift'));
      expect(gift.description, equals('A sample gift for testing'));
      expect(gift.category, equals('Electronics'));
      expect(gift.price, equals(99.99));
      expect(gift.status, equals('Available'));
      expect(gift.eventId, equals('event1'));
      expect(gift.pledgerId, equals('user123'));
      expect(gift.isPublished, equals(true));
    });

    test('CopyWith Test', () {
      final updatedGift = sampleGift.copyWith(
        name: 'Updated Gift',
        price: 79.99,
        status: 'Pledged',
      );

      expect(updatedGift.id, equals('1'));
      expect(updatedGift.name, equals('Updated Gift'));
      expect(updatedGift.price, equals(79.99));
      expect(updatedGift.status, equals('Pledged'));
      expect(updatedGift.description, equals('A sample gift for testing'));
      expect(updatedGift.category, equals('Electronics'));
      expect(updatedGift.eventId, equals('event1'));
      expect(updatedGift.pledgerId, equals('user123'));
      expect(updatedGift.isPublished, equals(true));
    });
  });
}
