import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/widgets/logout_widget.dart';
import 'package:pf2e_app/router.gr.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'), actions: [LogoutWidget()]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text('Home Page'),
            ElevatedButton(
              onPressed: () => context.router.push(AdventuresRoute()),
              child: Text('Go to Adventures'),
            ),
          ],
        ),
      ),
    );
  }
}
