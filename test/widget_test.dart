import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/features/home/home_page.dart';
import 'package:pf2e_app/features/login/login_page.dart';
import 'package:pf2e_app/features/profile/profile_page.dart';
import 'package:pf2e_app/locator.dart';
import 'package:watch_it/watch_it.dart';

// Annotation which generates the auth_service.mocks.dart library and the MockAuthService class.
@GenerateNiceMocks([MockSpec<AuthService>()])
import 'widget_test.mocks.dart';

final di = GetIt.instance;

void main() {
  setUpAll(() async {
    dotenv.loadFromString(
      envString: '',
      isOptional: true,
      mergeWith: {
        'AUTH0_DOMAIN': 'test-domain',
        'AUTH0_CLIENT_ID': 'test-client-id',
        'AUTH0_SCHEME': 'test-scheme',
        'SUPABASE_URL': 'https://test-supabase-url',
        'SUPABASE_PUBLISHABLE_KEY': 'test-supabase-key',
      },
    );

    configureDependencies();
    await di.allReady();
  });

  setUp(() {
    di.pushNewScope();
    di.registerSingleton<AuthService>(MockAuthService());
  });

  tearDown(() async {
    await di.popScope();
  });

  testWidgets('App authentication flow works as expected', (
    WidgetTester tester,
  ) async {
    mockNetworkImagesFor(() async {
      final mockAuthService = di<AuthService>() as MockAuthService;

      // Arrange: Mock AuthService to simulate no valid session
      when(mockAuthService.getSession()).thenAnswer((_) async => null);

      // Act: Load the App widget
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // Assert: Verify login page is displayed
      expect(find.byType(LoginPage), findsOneWidget);

      // Arrange: Mock AuthService to simulate successful login
      final mockCredentials = Credentials(
        accessToken: 'test-access-token',
        idToken: 'test-id-token',
        refreshToken: 'test-refresh-token',
        tokenType: 'Bearer',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: UserProfile(
          sub: 'test-user-id',
          pictureUrl: Uri.dataFromString('https://mock-host/mock-image.png'),
        ),
      );

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
