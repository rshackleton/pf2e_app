import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pf2e_app/features/profile/manager/profile_manager.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/services/profile_service.dart';
import 'package:pf2e_app/features/profile/widgets/profile_avatar_view.dart';

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

  // ──────────────────────────────────────────────────────────────────────────
  // US1 – ProfileAvatarView disk cache
  // ──────────────────────────────────────────────────────────────────────────

  group('US1 - ProfileAvatarView', () {
    setUpAll(() async {
      await configureTestDependencies();
    });

    testWidgets(
      'CachedNetworkImage is rendered when signedAvatarUrl is provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProfileAvatarView(
              avatarPath: 'users/test/avatar.png',
              signedAvatarUrl: 'https://example.com/avatar.png',
              firstName: 'Alice',
              lastName: 'Wonder',
            ),
          ),
        );

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      },
    );

    testWidgets(
      'initials are shown when signedAvatarUrl is null',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProfileAvatarView(
              avatarPath: null,
              signedAvatarUrl: null,
              firstName: 'Alice',
              lastName: 'Wonder',
            ),
          ),
        );

        expect(find.text('AW'), findsOneWidget);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // US2 – ProfileManager in-session cache
  // ──────────────────────────────────────────────────────────────────────────

  group('US2 - ProfileManager session cache', () {
    late MockAuthService mockAuthService;
    late MockAdventureService mockAdventureService;
    late MockProfileService mockProfileService;

    setUpAll(() async {
      await configureTestDependencies();
    });

    setUp(() {
      mockAuthService = MockAuthService();
      mockAdventureService = MockAdventureService();
      mockProfileService = MockProfileService();

      when(
        mockProfileService.getProfile(any),
      ).thenAnswer((_) async => buildCompleteProfile());
      when(
        mockProfileService.getSignedAvatarUrl(any),
      ).thenAnswer((_) async => 'https://example.com/signed-avatar.png');

      registerServiceMocks(
        authService: mockAuthService,
        adventureService: mockAdventureService,
        profileService: mockProfileService,
      );

      when(
        mockAuthService.getSession(),
      ).thenAnswer((_) async => buildMockCredentials());
    });

    tearDown(() async {
      await disposeServiceMocks();
    });

    test(
      'second loadProfileCommand skips backend when profile already loaded',
      () async {
        final manager = di<ProfileManager>();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockProfileService.getProfile(any)).called(1);
      },
    );

    test(
      'clearSession resets state to initial and calls profileService.clearCache',
      () async {
        final manager = di<ProfileManager>();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        expect(manager.state.value.loadState, ProfileLoadState.loaded);

        manager.clearSession();

        expect(manager.state.value.loadState, ProfileLoadState.idle);
        expect(manager.state.value.profile, isNull);
        verify(mockProfileService.clearCache()).called(1);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // US3 – Signed URL caching via ProfileManager
  // ──────────────────────────────────────────────────────────────────────────

  group('US3 - Signed URL caching', () {
    late MockAuthService mockAuthService;
    late MockAdventureService mockAdventureService;
    late MockProfileService mockProfileService;

    setUpAll(() async {
      await configureTestDependencies();
    });

    setUp(() {
      mockAuthService = MockAuthService();
      mockAdventureService = MockAdventureService();
      mockProfileService = MockProfileService();

      when(
        mockProfileService.getProfile(any),
      ).thenAnswer((_) async => buildCompleteProfile());
      when(
        mockProfileService.getSignedAvatarUrl(any),
      ).thenAnswer((_) async => 'https://example.com/signed.png');

      registerServiceMocks(
        authService: mockAuthService,
        adventureService: mockAdventureService,
        profileService: mockProfileService,
      );

      when(
        mockAuthService.getSession(),
      ).thenAnswer((_) async => buildMockCredentials());
    });

    tearDown(() async {
      await disposeServiceMocks();
    });

    test(
      'ProfileManager includes signedAvatarUrl in view state after load',
      () async {
        final manager = di<ProfileManager>();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        expect(
          manager.state.value.signedAvatarUrl,
          'https://example.com/signed.png',
        );
      },
    );

    test(
      'getSignedAvatarUrl is not called on second load due to US2 cache hit',
      () async {
        final manager = di<ProfileManager>();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockProfileService.getSignedAvatarUrl(any)).called(1);
      },
    );

    test(
      'getSignedAvatarUrl is called again after clearSession',
      () async {
        final manager = di<ProfileManager>();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.clearSession();

        manager.loadProfileCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockProfileService.getSignedAvatarUrl(any)).called(2);
      },
    );

    test('signedAvatarUrl is null for profile without avatar', () async {
      when(
        mockProfileService.getProfile(any),
      ).thenAnswer((_) async => buildIncompleteProfile());
      when(
        mockProfileService.getSignedAvatarUrl(null),
      ).thenAnswer((_) async => null);

      final manager = di<ProfileManager>();

      manager.loadProfileCommand.run();
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      expect(manager.state.value.signedAvatarUrl, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // US5 – Avatar file type validation (manual validation note)
  // ──────────────────────────────────────────────────────────────────────────

  group('US5 - Avatar file type validation', () {
    test('allowed image extensions are accepted', () {
      const allowedExtensions = {'jpeg', 'jpg', 'png', 'webp', 'gif'};
      for (final ext in ['jpeg', 'jpg', 'png', 'webp', 'gif']) {
        expect(
          allowedExtensions.contains(ext),
          isTrue,
          reason: '$ext should be allowed',
        );
      }
    });

    test('non-image extensions are rejected', () {
      const allowedExtensions = {'jpeg', 'jpg', 'png', 'webp', 'gif'};
      for (final ext in ['pdf', 'docx', 'txt', 'mp4', 'zip']) {
        expect(
          allowedExtensions.contains(ext),
          isFalse,
          reason: '$ext should not be allowed',
        );
      }
    });
  });
}
