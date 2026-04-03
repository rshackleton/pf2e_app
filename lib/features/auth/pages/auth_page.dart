import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/pages/adventures_page.dart';
import 'package:watch_it/watch_it.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/widgets/login_widget.dart';

/// Root authentication page.
/// Handles the three states: loading, authenticated, and unauthenticated.
class AuthPage extends WatchingWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = di<AuthManager>();

    // Initialize auth on first build
    callOnce((context) {
      authManager.initCommand.run();
    });

    // Watch the initialization state
    final isInitializing = watchValue(
      (AuthManager m) => m.initCommand.isRunning,
    );

    // Watch credentials
    final credentials = watchValue((AuthManager m) => m.credentials);

    // Watch error state
    final error = watchValue((AuthManager m) => m.authError);

    if (isInitializing) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (credentials != null) {
      final isLoggingOut = watchValue(
        (AuthManager m) => m.logoutCommand.isRunning,
      );

      // todo: replace with some kind of router that can handle more pages in the future
      return isLoggingOut
          ? const Center(child: CircularProgressIndicator.adaptive())
          : AdventuresPage();
    }

    final isLoggingIn = watchValue((AuthManager m) => m.loginCommand.isRunning);

    return isLoggingIn
        ? const Center(child: CircularProgressIndicator.adaptive())
        : LoginWidget(
            onLogin: () => authManager.loginCommand.run(),
            error: error,
          );
  }
}
