import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/router.dart';
import 'package:watch_it/watch_it.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = di<AuthService>();

    return IconButton(
      icon: Icon(Icons.logout),
      onPressed: () async {
        await authService.logout();
        di<AppRouter>().reevaluateGuards();
      },
      tooltip: 'Logout',
    );
  }
}
