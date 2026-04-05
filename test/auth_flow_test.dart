import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pf2e_app/features/home/home_page.dart';
import 'package:pf2e_app/features/login/login_page.dart';
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

    when(mockAdventureService.getAdventures()).thenAnswer((_) async => []);
    when(mockAdventureService.getAdventure(any)).thenAnswer((_) async => null);
    when(
      mockAdventureService.createAdventure(any),
    ).thenAnswer((_) async => buildAdventure(id: 1, name: 'placeholder'));
    when(mockAdventureService.deleteAdventure(any)).thenAnswer((_) async {});

    registerServiceMocks(
      authService: mockAuthService,
      adventureService: mockAdventureService,
    );
  });

  tearDown(() async {
    await disposeServiceMocks();
  });

  testWidgets('App authentication flow works as expected', (
    WidgetTester tester,
  ) async {
    mockNetworkImagesFor(() async {
      // Arrange: Mock AuthService to simulate no valid session
      when(mockAuthService.getSession()).thenAnswer((_) async => null);

      // Act: Load the App widget
      await pumpApp(tester);

      // Assert: Verify login page is displayed
      expect(find.byType(LoginPage), findsOneWidget);

      // Arrange: Mock AuthService to simulate successful login
      final mockCredentials = buildMockCredentials();

      when(
        mockAuthService.getSession(),
      ).thenAnswer((_) async => mockCredentials);
      when(mockAuthService.login()).thenAnswer((_) async => mockCredentials);

      // Act: Tap the Login button
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert: Verify home page is displayed
      verify(mockAuthService.login()).called(1);
      expect(find.byType(HomePage), findsOneWidget);

      // Act: Tap the Profile button
      await tester.tap(find.widgetWithIcon(IconButton, Icons.account_circle));
      await tester.pumpAndSettle();

      // Assert: Verify profile page is displayed
      expect(find.byType(ProfilePage), findsOneWidget);

      // Arrange: Mock AuthService to simulate logout
      when(mockAuthService.getSession()).thenAnswer((_) async => null);

      // Act: Tap the Logout button
      await tester.tap(find.widgetWithIcon(IconButton, Icons.logout));
      await tester.pumpAndSettle();

      // Assert: Verify login page is displayed
      verify(mockAuthService.logout()).called(1);
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
