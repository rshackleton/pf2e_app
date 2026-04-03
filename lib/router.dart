import 'package:auto_route/auto_route.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
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
      final authService = di<AuthService>();

      final credentials = await authService.getSession();

      if (credentials != null || resolver.routeName == LoginRoute.name) {
        resolver.next();
      } else {
        resolver.redirectUntil(
          LoginRoute(onResult: (didLogin) => resolver.next(didLogin)),
        );
      }
    }),
  ];
}
