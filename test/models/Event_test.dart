import 'package:flutter_test/flutter_test.dart';
import 'package:hedeyeti/models/Event.dart';

void main() {
  group('Event Model Tests', () {
    final sampleEvent = Event(
      id: '1',
      name: 'Sample Event',
      date: DateTime(2024, 12, 25),
      category: 'Birthday',
      location: 'Home',
      description: 'Sample Description',
      userId: '123',
      isPublished: true,
    );

    test('Formatted Date Test', () {
      expect(sampleEvent.formattedDate, '2024-12-25');
    });

    test('Event Serialization to Map', () {
      final expectedMap = {
        'id': '1',
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'userId': '123',
        'isPublished': true,
      };
      expect(sampleEvent.toMap(), equals(expectedMap));
    });

    test('Event Serialization to SQLite Map', () {
      final expectedSQLiteMap = {
        'id': '1',
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'user_id': '123',
        'is_published': 1,
      };
      expect(sampleEvent.toSQLite(), equals(expectedSQLiteMap));
    });

    test('Event Serialization to Firestore Map', () {
      final expectedFirestoreMap = {
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'userId': '123',
      };
      expect(sampleEvent.toFirestore(), equals(expectedFirestoreMap));
    });

    test('Event Deserialization from Map', () {
      final eventMap = {
        'id': '1',
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'userId': '123',
        'isPublished': true,
      };
      final event = Event.fromMap(eventMap);
      expect(event.id, equals('1'));
      expect(event.name, equals('Sample Event'));
      expect(event.date, equals(DateTime(2024, 12, 25)));
      expect(event.category, equals('Birthday'));
      expect(event.location, equals('Home'));
      expect(event.description, equals('Sample Description'));
      expect(event.userId, equals('123'));
      expect(event.isPublished, equals(true));
    });

    test('Event Deserialization from SQLite Map', () {
      final sqliteMap = {
        'id': '1',
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'user_id': '123',
        'is_published': 1,
      };
      final event = Event.fromSQLite(sqliteMap);
      expect(event.id, equals('1'));
      expect(event.name, equals('Sample Event'));
      expect(event.date, equals(DateTime(2024, 12, 25)));
      expect(event.category, equals('Birthday'));
      expect(event.location, equals('Home'));
      expect(event.description, equals('Sample Description'));
      expect(event.userId, equals('123'));
      expect(event.isPublished, equals(true));
    });

    test('Event Deserialization from Firestore Map', () {
      final firestoreMap = {
        'name': 'Sample Event',
        'date': '2024-12-25T00:00:00.000',
        'category': 'Birthday',
        'location': 'Home',
        'description': 'Sample Description',
        'userId': '123',
      };
      final event = Event.fromFirestore(firestoreMap, '1');
      expect(event.id, equals('1'));
      expect(event.name, equals('Sample Event'));
      expect(event.date, equals(DateTime(2024, 12, 25)));
      expect(event.category, equals('Birthday'));
      expect(event.location, equals('Home'));
      expect(event.description, equals('Sample Description'));
      expect(event.userId, equals('123'));
      expect(event.isPublished, equals(true));
    });
  });
}
