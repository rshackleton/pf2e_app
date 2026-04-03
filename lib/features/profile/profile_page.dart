import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/widgets/logout_widget.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [LogoutWidget()],
            centerTitle: true,
            pinned: true,
            title: Text('Some App Name'),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [Text('TODO: Add account management functions')],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
