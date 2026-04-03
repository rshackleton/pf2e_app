import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  final void Function(bool success) onResult;

  const LoginPage({super.key, required this.onResult});

  @override
  Widget build(BuildContext context) {
    final authService = di<AuthService>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text('Welcome! Please log in.'),
            ElevatedButton(
              onPressed: () async {
                final credentials = await authService.login();
                onResult(credentials != null);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
