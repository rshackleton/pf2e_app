import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/router.dart';
import 'package:pf2e_app/router.gr.dart';
import 'package:watch_it/watch_it.dart';

class App extends WatchingWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = di<AppRouter>();

    callOnce((context) {
      final authManager = di<AuthManager>();
      authManager.initCommand.run();
    });

    final isInitialising = watchValue(
      (AuthManager m) => m.initCommand.isRunning,
    );

    // Ensure we trigger login prompt if the credentials are removed (e.g. logout)
    registerHandler(
      select: (AuthManager m) => m.credentials,
      handler: (_, credentials, _) {
        if (credentials == null) {
          // Clear stack and force-redirect to route, triggering the guards.
          appRouter.replaceAll([HomeRoute()]);
        }
      },
    );

    // Ensure we have initialised the auth manager before rendering the application.
    return isInitialising
        ? CircularProgressIndicator.adaptive()
        : MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.config(),
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Colors.deepOrange,
              ),
            ),
          );
  }
}
