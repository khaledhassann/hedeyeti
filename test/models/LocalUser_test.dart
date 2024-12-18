import 'package:flutter_test/flutter_test.dart';
import 'package:hedeyeti/models/LocalUser.dart';

void main() {
  group('LocalUser Model Tests', () {
    final sampleUser = LocalUser(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      profilePicture: 'assets/profile.png',
      isMe: true,
      notificationPush: true,
    );

    test('Serialization to SQLite Map', () {
      final expectedMap = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'profilePicture': 'assets/profile.png',
        'isMe': 1,
        'notificationPush': 1,
      };

      expect(sampleUser.toSQLite(), equals(expectedMap));
    });

    test('Serialization to Firestore Map', () {
      final expectedMap = {
        'name': 'Test User',
        'email': 'test@example.com',
        'profilePicture': 'assets/profile.png',
        'notificationPush': true,
      };

      expect(sampleUser.toFirestore(), equals(expectedMap));
    });

    test('Deserialization from SQLite Map', () {
      final sqliteMap = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'profilePicture': 'assets/profile.png',
        'isMe': 1,
        'notificationPush': 1,
      };

      final user = LocalUser.fromSQLite(sqliteMap);

      expect(user.id, equals('1'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.profilePicture, equals('assets/profile.png'));
      expect(user.isMe, equals(true));
      expect(user.notificationPush, equals(true));
    });

    test('Deserialization from Firestore Map', () {
      final firestoreMap = {
        'name': 'Test User',
        'email': 'test@example.com',
        'profilePicture': 'assets/profile.png',
        'notificationPush': true,
      };

      final user = LocalUser.fromFirestore(firestoreMap, '1');

      expect(user.id, equals('1'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.profilePicture, equals('assets/profile.png'));
      expect(user.isMe, equals(false));
      expect(user.notificationPush, equals(true));
    });

    test('Fallback User Test', () {
      final fallbackUser = LocalUser.fallbackUser();

      expect(fallbackUser.id, equals(''));
      expect(fallbackUser.name, equals('Guest'));
      expect(fallbackUser.email, equals('guest@example.com'));
      expect(fallbackUser.profilePicture, equals(''));
      expect(fallbackUser.isMe, equals(true));
      expect(fallbackUser.notificationPush, equals(false));
    });

    test('CopyWith Test', () {
      final updatedUser = sampleUser.copyWith(
        name: 'Updated User',
        email: 'updated@example.com',
      );

      expect(updatedUser.id, equals('1'));
      expect(updatedUser.name, equals('Updated User'));
      expect(updatedUser.email, equals('updated@example.com'));
      expect(updatedUser.profilePicture, equals('assets/profile.png'));
      expect(updatedUser.isMe, equals(true));
      expect(updatedUser.notificationPush, equals(true));
    });
  });
}
