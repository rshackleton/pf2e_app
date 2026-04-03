import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/widgets/adventures_list.dart';
import 'package:pf2e_app/features/adventures/widgets/new_adventure_button.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class AdventuresPage extends WatchingWidget {
  const AdventuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [NewAdventureButton()],
            centerTitle: true,
            pinned: true,
            title: Text('Adventures'),
          ),
          AdventuresListWidget(),
        ],
      ),
    );
  }
}
