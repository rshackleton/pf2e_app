import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pf2e_app/features/adventures/adventure_detail_root_page.dart';
import 'package:pf2e_app/features/adventures/adventures_page.dart';
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
      final mockCredentials = buildMockCredentials();
      final existingAdventure = buildAdventure(id: 1, name: 'Old Adventure');
      final createdAdventure = buildAdventure(id: 2, name: 'My New Adventure');

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

      verify(mockAdventureService.getAdventure(createdAdventure.id)).called(1);
      expect(find.byType(AdventureDetailRootPage), findsOneWidget);
      expect(find.text('My New Adventure'), findsOneWidget);
      expect(find.textContaining('Created at:'), findsOneWidget);
    },
  );
}
