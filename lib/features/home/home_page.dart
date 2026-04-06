import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/profile/manager/profile_manager.dart';
import 'package:pf2e_app/features/profile/widgets/profile_avatar_view.dart';
import 'package:pf2e_app/router.gr.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class HomePage extends WatchingWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = watchValue((ProfileManager m) => m.state);

    callOnce((context) {
      final m = di<ProfileManager>();
      m.loadProfileCommand.run();
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: () => context.router.navigate(ProfileRoute()),
                icon: ProfileAvatarView(
                  avatarPath: profileState.profile?.avatarPath,
                  firstName: profileState.profile?.firstName,
                  lastName: profileState.profile?.lastName,
                  radius: 14,
                ),
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
