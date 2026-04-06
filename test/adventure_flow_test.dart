import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pf2e_app/features/adventures/adventure_detail_root_page.dart';
import 'package:pf2e_app/features/adventures/adventures_page.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/new_adventure_page.dart';
import 'package:pf2e_app/features/home/home_page.dart';

import 'test_helpers.dart';
import 'test_mocks.mocks.dart';

void main() {
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

    registerServiceMocks(
      authService: mockAuthService,
      adventureService: mockAdventureService,
      profileService: mockProfileService,
    );
  });

  tearDown(() async {
    await disposeServiceMocks();
  });

  testWidgets(
    'navigates to adventures, creates a new adventure, and opens details',
    (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final mockCredentials = buildMockCredentials();
        final existingAdventure = buildAdventure(id: 1, name: 'Old Adventure');
        final createdAdventure = buildAdventure(
          id: 2,
          name: 'My New Adventure',
        );

        when(
          mockAuthService.getSession(),
        ).thenAnswer((_) async => mockCredentials);
        when(
          mockAdventureService.getAdventures(),
        ).thenAnswer((_) async => [existingAdventure]);
        when(
          mockAdventureService.createAdventure('My New Adventure'),
        ).thenAnswer((_) async => createdAdventure);
        when(
          mockAdventureService.getAdventure(createdAdventure.id),
        ).thenAnswer((_) async => createdAdventure);

        await pumpApp(tester);

        expect(find.byType(HomePage), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Go to Adventures'));
        await tester.pumpAndSettle();

        expect(find.byType(AdventuresPage), findsOneWidget);
        expect(find.text('Old Adventure'), findsOneWidget);

        await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
        await tester.pumpAndSettle();

        expect(find.byType(NewAdventurePage), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), 'My New Adventure');
        await tester.tap(find.widgetWithText(FilledButton, 'Create'));
        await tester.pumpAndSettle();

        verify(
          mockAdventureService.createAdventure('My New Adventure'),
        ).called(1);
        expect(find.byType(AdventuresPage), findsOneWidget);
        expect(find.text('My New Adventure'), findsOneWidget);

        await tester.tap(find.text('My New Adventure'));
        await tester.pumpAndSettle();

        verify(
          mockAdventureService.getAdventure(createdAdventure.id),
        ).called(1);
        expect(find.byType(AdventureDetailRootPage), findsOneWidget);
        expect(find.text('My New Adventure'), findsOneWidget);
        expect(find.textContaining('Created at:'), findsOneWidget);
      });
    },
  );

  group('US2 - AdventureManager session cache', () {
    test(
      'second getAdventuresCommand invocation skips backend when already loaded',
      () async {
        when(
          mockAdventureService.getAdventures(),
        ).thenAnswer((_) async => [buildAdventure(id: 1, name: 'Test')]);

        final manager = di<AdventureManager>();

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockAdventureService.getAdventures()).called(1);
      },
    );

    test(
      'clearSession resets _hasLoaded and empties the adventures list',
      () async {
        when(
          mockAdventureService.getAdventures(),
        ).thenAnswer((_) async => [buildAdventure(id: 1, name: 'Test')]);

        final manager = di<AdventureManager>();

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        expect(manager.adventures.value, isNotEmpty);

        manager.clearSession();

        expect(manager.adventures.value, isEmpty);

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockAdventureService.getAdventures()).called(2);
      },
    );

    test(
      'createAdventure prepends to list without resetting hasLoaded',
      () async {
        when(
          mockAdventureService.getAdventures(),
        ).thenAnswer(
          (_) async => [buildAdventure(id: 1, name: 'Existing')],
        );
        when(
          mockAdventureService.createAdventure(any),
        ).thenAnswer((_) async => buildAdventure(id: 2, name: 'New'));

        final manager = di<AdventureManager>();

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.createAdventureCommand.run('New');
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        manager.getAdventuresCommand.run();
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        verify(mockAdventureService.getAdventures()).called(1);
      },
    );
  });

  group('US4 - Adventure name length validation', () {
    testWidgets(
      'name exceeding 200 characters fails form validation',
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          when(
            mockAuthService.getSession(),
          ).thenAnswer((_) async => buildMockCredentials());
          when(
            mockAdventureService.getAdventures(),
          ).thenAnswer((_) async => []);

          await pumpApp(tester);

          await tester.tap(find.widgetWithText(FilledButton, 'Go to Adventures'));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
          await tester.pumpAndSettle();

          expect(find.byType(NewAdventurePage), findsOneWidget);

          await tester.enterText(find.byType(TextFormField), 'a' * 201);
          await tester.tap(find.widgetWithText(FilledButton, 'Create'));
          await tester.pump();

          expect(
            find.text('Adventure name must be 200 characters or fewer.'),
            findsOneWidget,
          );
        });
      },
    );

    testWidgets(
      'name at exactly 200 characters passes validation',
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          when(
            mockAuthService.getSession(),
          ).thenAnswer((_) async => buildMockCredentials());
          when(
            mockAdventureService.getAdventures(),
          ).thenAnswer((_) async => []);
          when(
            mockAdventureService.createAdventure(any),
          ).thenAnswer(
            (_) async => buildAdventure(id: 1, name: 'a' * 200),
          );

          await pumpApp(tester);

          await tester.tap(find.widgetWithText(FilledButton, 'Go to Adventures'));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextFormField), 'a' * 200);
          await tester.tap(find.widgetWithText(FilledButton, 'Create'));
          await tester.pump();

          expect(
            find.text('Adventure name must be 200 characters or fewer.'),
            findsNothing,
          );
        });
      },
    );

    testWidgets(
      'empty name still triggers the existing non-empty validator',
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          when(
            mockAuthService.getSession(),
          ).thenAnswer((_) async => buildMockCredentials());
          when(
            mockAdventureService.getAdventures(),
          ).thenAnswer((_) async => []);

          await pumpApp(tester);

          await tester.tap(find.widgetWithText(FilledButton, 'Go to Adventures'));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(FilledButton, 'Create'));
          await tester.pump();

          expect(
            find.text('Please enter the adventure name.'),
            findsOneWidget,
          );
        });
      },
    );
  });
}
