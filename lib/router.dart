import 'package:auto_route/auto_route.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/router.gr.dart';
import 'package:watch_it/watch_it.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: AdventuresRoute.page),
    AutoRoute(
      page: AdventureDetailRootRoute.page,
      children: [AutoRoute(page: AdventureDetailHomeRoute.page, initial: true)],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    AutoRouteGuard.simple((resolver, router) async {
      final authManager = di<AuthManager>();

      // We can access this under the assumption that we initialisated in app.dart
      final credentials = authManager.credentials.value;

      if (credentials != null || resolver.routeName == LoginRoute.name) {
        resolver.next();
      } else {
        resolver.redirectUntil(
          LoginRoute(
            onLogin: () {
              resolver.next();
            },
          ),
        );
      }
    }),
  ];
}
