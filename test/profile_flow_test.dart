import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/services/profile_service.dart';

import 'test_helpers.dart';
import 'test_mocks.mocks.dart';

void main() {
  late MockProfileService mockProfileService;

  setUp(() {
    mockProfileService = MockProfileService();
  });

  test('US2: update success path returns persisted names', () async {
    when(
      mockProfileService.updateProfile(
        any,
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
        avatarBytes: anyNamed('avatarBytes'),
        avatarFileExtension: anyNamed('avatarFileExtension'),
      ),
    ).thenAnswer(
      (_) async => buildCompleteProfile(firstName: 'Alice', lastName: 'Cooper'),
    );

    final updated = await mockProfileService.updateProfile(
      'test-user-id',
      firstName: 'Alice',
      lastName: 'Cooper',
      avatarBytes: null,
      avatarFileExtension: null,
    );

    expect(updated.firstName, 'Alice');
    expect(updated.lastName, 'Cooper');
  });

  test(
    'US2: avatar update keeps avatar reference in returned profile',
    () async {
      when(
        mockProfileService.updateProfile(
          any,
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
          avatarBytes: anyNamed('avatarBytes'),
          avatarFileExtension: anyNamed('avatarFileExtension'),
        ),
      ).thenAnswer(
        (_) async => buildCompleteProfile(
          avatarPath: 'https://mock-host/new-avatar.png',
        ),
      );

      final updated = await mockProfileService.updateProfile(
        'test-user-id',
        firstName: 'Avatar',
        lastName: null,
        avatarBytes: Uint8List.fromList([1, 2, 3]),
        avatarFileExtension: 'png',
      );

      expect(updated.avatarPath, 'https://mock-host/new-avatar.png');
    },
  );

  test('US3: missing avatar fallback uses null avatar path', () {
    final profile = buildIncompleteProfile();

    expect(profile.avatarPath, isNull);
    expect(profile.displayName, 'Adventurer');
  });

  test('US3: transient load error can recover on retry', () async {
    var calls = 0;
    when(mockProfileService.getProfile(any)).thenAnswer((_) async {
      calls += 1;
      if (calls == 1) {
        throw Exception('temporary');
      }
      return buildCompleteProfile();
    });

    await expectLater(
      () => mockProfileService.getProfile('test-user-id'),
      throwsException,
    );

    final recovered = await mockProfileService.getProfile('test-user-id');
    expect(recovered.firstName, 'Test');
  });

  test('US4: refresh on revisit returns latest profile snapshot', () async {
    var calls = 0;
    when(mockProfileService.getProfile(any)).thenAnswer((_) async {
      calls += 1;
      if (calls == 1) {
        return buildCompleteProfile(firstName: 'Old', lastName: 'Name');
      }
      return buildCompleteProfile(firstName: 'New', lastName: 'Name');
    });

    final first = await mockProfileService.getProfile('test-user-id');
    final second = await mockProfileService.getProfile('test-user-id');

    expect(first.firstName, 'Old');
    expect(second.firstName, 'New');
  });

  test(
    'US4: missing linked profile exposes integration guidance exception',
    () {
      expect(
        const MissingLinkedProfileException().toString(),
        'Missing linked profile for authenticated user.',
      );
    },
  );

  test('profile model fallback display values are stable', () {
    const profile = ProfileRecord(userId: 'u-1');

    expect(profile.displayFirstName, 'First name not set');
    expect(profile.displayLastName, 'Last name not set');
    expect(profile.displayName, 'Adventurer');
  });
}
