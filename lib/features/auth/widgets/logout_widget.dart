import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:watch_it/watch_it.dart';

class LogoutWidget extends WatchingWidget {
  const LogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = di<AuthManager>();

    return IconButton(
      icon: Icon(Icons.logout),
      onPressed: () async {
        authManager.logoutCommand.run();
      },
      tooltip: 'Logout',
    );
  }
}
