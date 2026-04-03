import 'package:get_it/get_it.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/auth/services/auth0_service.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/router.dart';

final di = GetIt.instance;

/// Configures all services and managers in the dependency injection container.
Future<void> configureDependencies() async {
  di.registerSingleton(AppRouter());

  di.registerSingletonAsync<AuthService>(() => Auth0Service().init());

  di.registerSingleton<AdventureService>(AdventureService());

  di.registerLazySingleton<AdventureManager>(
    () => AdventureManager(),
    dispose: (m) => m.dispose(),
  );
}
