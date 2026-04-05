import 'package:get_it/get_it.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/services/auth0_service.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/features/profile/manager/profile_manager.dart';
import 'package:pf2e_app/features/profile/services/profile_service.dart';
import 'package:pf2e_app/router.dart';

final di = GetIt.instance;

/// Configures all services and managers in the dependency injection container.
Future<void> configureDependencies() async {
  di.registerSingleton(AppRouter());

  di.registerSingleton<AdventureService>(AdventureService());
  di.registerSingleton<AuthService>(Auth0Service());
  di.registerSingleton<ProfileService>(SupabaseProfileService());

  di.registerLazySingleton<AdventureManager>(
    () => AdventureManager(),
    dispose: (m) => m.dispose(),
  );

  di.registerLazySingleton<AuthManager>(
    () => AuthManager(),
    dispose: (m) => m.dispose(),
  );

  di.registerLazySingleton<ProfileManager>(
    () => ProfileManager(),
    dispose: (m) => m.dispose(),
  );
}
