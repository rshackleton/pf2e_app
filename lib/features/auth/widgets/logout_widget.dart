import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:watch_it/watch_it.dart';

class LogoutWidget extends WatchingWidget {
  const LogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = di<AuthManager>();

    final credentials = watchValue((AuthManager m) => m.credentials);

    final isLoggingOut = watchValue(
      (AuthManager m) => m.logoutCommand.isRunning,
    );

    if (credentials == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: isLoggingOut ? null : () => authManager.logoutCommand.run(),
      icon: Icon(Icons.logout),
    );
  }
}
