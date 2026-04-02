import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf2e_app/features/auth/pages/auth_page.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';
import 'package:watch_it/watch_it.dart';

class TestAuthService implements AuthService {
  @override
  Future<Credentials?> login() async {
    return null; // Simulate no credentials
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Credentials> getSession() async {
    throw Exception('No session'); // Simulate no valid session
  }

  @override
  Future<bool> hasValidCredentials() async {
    return false; // Simulate not authenticated
  }
}

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
    di.registerSingleton<AuthService>(TestAuthService());
  });

  tearDown(() async {
    await di.popScope();
  });

  testWidgets('AuthPage renders Login button by default', (
    WidgetTester tester,
  ) async {
    // Act: Build the AuthPage
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Assert: Verify Login button is present
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
