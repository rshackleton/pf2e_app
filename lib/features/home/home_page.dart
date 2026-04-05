import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/router.gr.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              IconButton(
                onPressed: () => context.router.navigate(ProfileRoute()),
                icon: Icon(Icons.account_circle),
              ),
            ],
            centerTitle: true,
            pinned: true,
            title: Text('Some App Name'),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  FilledButton(
                    onPressed: () => context.router.navigate(AdventuresRoute()),
                    child: Text('Go to Adventures'),
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
