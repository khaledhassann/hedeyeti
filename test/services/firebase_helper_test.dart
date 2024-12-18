import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import 'package:hedeyeti/models/Event.dart';

// Generate the mock class
@GenerateMocks([FirebaseHelper])
import 'firebase_helper_test.mocks.dart'; // Import the generated file

void main() {
  late MockFirebaseHelper mockFirebaseHelper;

  setUp(() {
    mockFirebaseHelper = MockFirebaseHelper();
  });

  test('Insert event into Firestore', () async {
    // Arrange
    final testEvent = Event(
      id: '1',
      name: 'Test Event',
      date: DateTime.now(),
      category: 'Birthday',
      location: 'Home',
      description: 'A test event description.',
      userId: '123',
      isPublished: false,
    );

    when(mockFirebaseHelper.insertEventInFirestore(testEvent))
        .thenAnswer((_) async => Future.value());

    // Act
    await mockFirebaseHelper.insertEventInFirestore(testEvent);

    // Assert
    verify(mockFirebaseHelper.insertEventInFirestore(testEvent)).called(1);
  });
}
