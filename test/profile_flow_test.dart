import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pf2e_app/features/home/home_page.dart';
import 'package:pf2e_app/features/profile/profile_page.dart';

import 'test_helpers.dart';
import 'test_mocks.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockAdventureService mockAdventureService;

  setUpAll(() async {
    await configureTestDependencies();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAdventureService = MockAdventureService();

    registerServiceMocks(
      authService: mockAuthService,
      adventureService: mockAdventureService,
    );
  });

  tearDown(() async {
    await disposeServiceMocks();
  });

  testWidgets('opens profile page and displays user information', (
    WidgetTester tester,
  ) async {
    mockNetworkImagesFor(() async {
      final mockCredentials = buildMockCredentials();

      when(
        mockAuthService.getSession(),
      ).thenAnswer((_) async => mockCredentials);

      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.account_circle));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Some App Name'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.logout), findsOneWidget);
    });
  });
}
