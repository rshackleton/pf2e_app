import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/features/profile/manager/profile_manager.dart';
import 'package:pf2e_app/features/profile/model/profile_record.dart';
import 'package:pf2e_app/features/profile/services/profile_service.dart';
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
  required MockProfileService profileService,
}) {
  di.pushNewScope();
  di.registerSingleton<AuthService>(authService);
  di.registerSingleton<AdventureService>(adventureService);
  di.registerSingleton<ProfileService>(profileService);
  di.registerLazySingleton<AuthManager>(
    () => AuthManager(),
    dispose: (m) => m.dispose(),
  );
  di.registerLazySingleton<AdventureManager>(
    () => AdventureManager(),
    dispose: (m) => m.dispose(),
  );
  di.registerLazySingleton<ProfileManager>(
    () => ProfileManager(),
    dispose: (m) => m.dispose(),
  );
}

Future<void> disposeServiceMocks() async {
  await di.popScope();
}

Credentials buildMockCredentials({
  Uri? pictureUrl,
  bool includePicture = true,
}) {
  return Credentials(
    accessToken: 'test-access-token',
    idToken: 'test-id-token',
    refreshToken: 'test-refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    user: UserProfile(
      sub: 'test-user-id',
      pictureUrl: includePicture
          ? (pictureUrl ??
                Uri.dataFromString('https://mock-host/mock-image.png'))
          : null,
      name: 'Test User',
    ),
  );
}

Adventure buildAdventure({
  required int id,
  required String name,
  DateTime? createdAt,
  String userId = 'test-user-id',
}) {
  return Adventure(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    userId: userId,
  );
}

ProfileRecord buildCompleteProfile({
  String userId = 'test-user-id',
  String firstName = 'Test',
  String lastName = 'User',
  String avatarPath = 'https://mock-host/mock-avatar.png',
}) {
  return ProfileRecord(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    avatarPath: avatarPath,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

ProfileRecord buildIncompleteProfile({String userId = 'test-user-id'}) {
  return ProfileRecord(
    userId: userId,
    firstName: null,
    lastName: null,
    avatarPath: null,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}
