import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class LoginPage extends WatchingWidget {
  final void Function() onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final authManager = di<AuthManager>();

    final credentials = watchValue((AuthManager m) => m.credentials);

    final isLoginRunning = watchValue(
      (AuthManager m) => m.loginCommand.isRunning,
    );

    registerHandler(
      select: (AuthManager m) => m.credentials,
      handler: (context, credentials, _) {
        onLogin();
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            title: Text('Some App Name'),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: credentials != null || isLoginRunning
                  ? CircularProgressIndicator.adaptive()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        Text('Welcome! Please log in.'),
                        FilledButton(
                          onPressed: () async {
                            authManager.loginCommand.run();
                          },
                          child: Text('Login'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
