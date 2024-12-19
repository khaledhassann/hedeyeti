// Mocks generated by Mockito 5.4.2 from annotations
// in hedeyeti/test/services/database_helper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:cloud_firestore/cloud_firestore.dart' as _i2;
import 'package:hedeyeti/models/Event.dart' as _i6;
import 'package:hedeyeti/models/Gift.dart' as _i7;
import 'package:hedeyeti/models/LocalUser.dart' as _i5;
import 'package:hedeyeti/services/firebase_helper.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeCollectionReference_0<T extends Object?> extends _i1.SmartFake
    implements _i2.CollectionReference<T> {
  _FakeCollectionReference_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FirebaseHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseHelper extends _i1.Mock implements _i3.FirebaseHelper {
  MockFirebaseHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.CollectionReference<Object?> get users => (super.noSuchMethod(
        Invocation.getter(#users),
        returnValue: _FakeCollectionReference_0<Object?>(
          this,
          Invocation.getter(#users),
        ),
      ) as _i2.CollectionReference<Object?>);

  @override
  _i2.CollectionReference<Object?> get events => (super.noSuchMethod(
        Invocation.getter(#events),
        returnValue: _FakeCollectionReference_0<Object?>(
          this,
          Invocation.getter(#events),
        ),
      ) as _i2.CollectionReference<Object?>);

  @override
  _i2.CollectionReference<Object?> get gifts => (super.noSuchMethod(
        Invocation.getter(#gifts),
        returnValue: _FakeCollectionReference_0<Object?>(
          this,
          Invocation.getter(#gifts),
        ),
      ) as _i2.CollectionReference<Object?>);

  @override
  _i2.CollectionReference<Object?> get friends => (super.noSuchMethod(
        Invocation.getter(#friends),
        returnValue: _FakeCollectionReference_0<Object?>(
          this,
          Invocation.getter(#friends),
        ),
      ) as _i2.CollectionReference<Object?>);

  @override
  _i4.Future<_i5.LocalUser?> registerUser(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #registerUser,
          [
            email,
            password,
          ],
        ),
        returnValue: _i4.Future<_i5.LocalUser?>.value(),
      ) as _i4.Future<_i5.LocalUser?>);

  @override
  _i4.Future<_i5.LocalUser?> loginUser(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loginUser,
          [
            email,
            password,
          ],
        ),
        returnValue: _i4.Future<_i5.LocalUser?>.value(),
      ) as _i4.Future<_i5.LocalUser?>);

  @override
  _i4.Future<void> logoutUser() => (super.noSuchMethod(
        Invocation.method(
          #logoutUser,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i5.LocalUser?> getCurrentUser() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [],
        ),
        returnValue: _i4.Future<_i5.LocalUser?>.value(),
      ) as _i4.Future<_i5.LocalUser?>);

  @override
  _i4.Future<_i5.LocalUser?> getUserFromFirestore(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getUserFromFirestore,
          [userId],
        ),
        returnValue: _i4.Future<_i5.LocalUser?>.value(),
      ) as _i4.Future<_i5.LocalUser?>);

  @override
  _i4.Future<void> updateUserInFirestore({
    required String? userId,
    String? name,
    String? email,
    String? profilePicture,
    bool? notificationPush,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUserInFirestore,
          [],
          {
            #userId: userId,
            #name: name,
            #email: email,
            #profilePicture: profilePicture,
            #notificationPush: notificationPush,
          },
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> addFriendInFirestore(
    String? userId,
    String? friendId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addFriendInFirestore,
          [
            userId,
            friendId,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> removeFriendInFirestore(
    String? userId,
    String? friendId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeFriendInFirestore,
          [
            userId,
            friendId,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i5.LocalUser?> searchUserByEmailInFirestore(String? email) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchUserByEmailInFirestore,
          [email],
        ),
        returnValue: _i4.Future<_i5.LocalUser?>.value(),
      ) as _i4.Future<_i5.LocalUser?>);

  @override
  _i4.Future<bool> isFriendInFirestore(
    String? userId,
    String? friendId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #isFriendInFirestore,
          [
            userId,
            friendId,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<List<_i5.LocalUser>> getFriendsFromFirestore(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFriendsFromFirestore,
          [userId],
        ),
        returnValue: _i4.Future<List<_i5.LocalUser>>.value(<_i5.LocalUser>[]),
      ) as _i4.Future<List<_i5.LocalUser>>);

  @override
  _i4.Future<void> insertEventInFirestore(_i6.Event? event) =>
      (super.noSuchMethod(
        Invocation.method(
          #insertEventInFirestore,
          [event],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateEventInFirestore({
    required String? eventId,
    String? name,
    DateTime? date,
    String? category,
    String? location,
    String? description,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateEventInFirestore,
          [],
          {
            #eventId: eventId,
            #name: name,
            #date: date,
            #category: category,
            #location: location,
            #description: description,
          },
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> deleteEventInFirestore(String? eventId) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteEventInFirestore,
          [eventId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<List<_i6.Event>>? getEventsForUserFromFireStore(String? userId) =>
      (super.noSuchMethod(Invocation.method(
        #getEventsForUserFromFireStore,
        [userId],
      )) as _i4.Future<List<_i6.Event>>?);

  @override
  _i4.Future<_i6.Event?> getEventById(String? eventId) => (super.noSuchMethod(
        Invocation.method(
          #getEventById,
          [eventId],
        ),
        returnValue: _i4.Future<_i6.Event?>.value(),
      ) as _i4.Future<_i6.Event?>);

  @override
  _i4.Future<_i7.Gift?> getGiftById(String? giftId) => (super.noSuchMethod(
        Invocation.method(
          #getGiftById,
          [giftId],
        ),
        returnValue: _i4.Future<_i7.Gift?>.value(),
      ) as _i4.Future<_i7.Gift?>);

  @override
  _i4.Future<List<_i7.Gift>?> getGiftsForEventFromFirestore(String? eventId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getGiftsForEventFromFirestore,
          [eventId],
        ),
        returnValue: _i4.Future<List<_i7.Gift>?>.value(),
      ) as _i4.Future<List<_i7.Gift>?>);

  @override
  _i4.Future<List<_i7.Gift>?> getPledgedGiftsFromUserFromFirestore(
          String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPledgedGiftsFromUserFromFirestore,
          [userId],
        ),
        returnValue: _i4.Future<List<_i7.Gift>?>.value(),
      ) as _i4.Future<List<_i7.Gift>?>);

  @override
  _i4.Future<void> insertGiftInFirestore(_i7.Gift? gift) => (super.noSuchMethod(
        Invocation.method(
          #insertGiftInFirestore,
          [gift],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateGiftInFirestore({
    required String? giftId,
    String? name,
    String? category,
    String? description,
    double? price,
    String? status,
    String? pledgerId,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateGiftInFirestore,
          [],
          {
            #giftId: giftId,
            #name: name,
            #category: category,
            #description: description,
            #price: price,
            #status: status,
            #pledgerId: pledgerId,
          },
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> deleteGiftInFirestore(String? giftId) => (super.noSuchMethod(
        Invocation.method(
          #deleteGiftInFirestore,
          [giftId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  void listenForPledgedGifts(String? userId) => super.noSuchMethod(
        Invocation.method(
          #listenForPledgedGifts,
          [userId],
        ),
        returnValueForMissingStub: null,
      );
}
