import 'package:get_it/get_it.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/services/auth0_service.dart';

final di = GetIt.instance;

/// Configures all services and managers in the dependency injection container.
Future<void> configureDependencies() async {
  // Auth0 API Service - async singleton
  di.registerSingletonAsync<Auth0Service>(() => Auth0Service().init());

  // Auth Manager - lazy singleton
  di.registerLazySingleton<AuthManager>(
    () => AuthManager(),
    dispose: (m) => m.dispose(),
  );
}
