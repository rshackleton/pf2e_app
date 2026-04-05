import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/features/auth/widgets/logout_widget.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class ProfilePage extends WatchingWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = watchValue(
      (AuthManager m) => m.credentials.map((Credentials? c) => c?.user),
    );

    // TODO: Fetch profile data from supabase for user
    // final profile = watchValue((ProfileManager m) => m.profile);
    // profile.firstName
    // profile.lastName
    // profile.avatar

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
                children: [
                  CircleAvatar(
                    backgroundImage: user?.pictureUrl != null
                        ? NetworkImage(user!.pictureUrl.toString())
                        : null,
                    radius: 64,
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
                    child: FittedBox(
                      child: Text(
                        user?.name ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
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
