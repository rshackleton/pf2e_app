import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';
import 'package:watch_it/watch_it.dart';

import 'test_mocks.mocks.dart';

final di = GetIt.instance;

bool _didConfigureDependencies = false;

Future<void> configureTestDependencies() async {
  if (_didConfigureDependencies) {
    return;
  }

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

  await configureDependencies();
  await di.allReady();
  _didConfigureDependencies = true;
}

void registerServiceMocks({
  required MockAuthService authService,
  required MockAdventureService adventureService,
}) {
  di.pushNewScope();
  di.registerSingleton<AuthService>(authService);
  di.registerSingleton<AdventureService>(adventureService);
}

Future<void> disposeServiceMocks() async {
  await di.popScope();
}

Credentials buildMockCredentials() {
  return Credentials(
    accessToken: 'test-access-token',
    idToken: 'test-id-token',
    refreshToken: 'test-refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    user: UserProfile(
      sub: 'test-user-id',
      pictureUrl: Uri.dataFromString('https://mock-host/mock-image.png'),
      name: 'Test User',
    ),
  );
}

Adventure buildAdventure({
  required int id,
  required String name,
  DateTime? createdAt,
  String createdBy = 'test-user-id',
}) {
  return Adventure(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    createdBy: createdBy,
  );
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}
