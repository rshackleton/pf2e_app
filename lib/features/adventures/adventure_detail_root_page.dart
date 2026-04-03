import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class AdventureDetailRootPage extends WatchingWidget {
  final int adventureId;

  const AdventureDetailRootPage({
    super.key,
    @pathParam required this.adventureId,
  });

  @override
  Widget build(BuildContext context) {
    final adventureManager = di<AdventureManager>();

    callOnce((context) {
      adventureManager.getAdventureCommand.run(adventureId);
    });

    final isFetching = watchValue(
      (AdventureManager m) => m.getAdventureCommand.isRunning,
    );

    final adventure = watchValue((AdventureManager m) => m.adventure);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            title: isFetching || adventure == null
                ? null
                : Text(adventure.name),
          ),
          SliverToBoxAdapter(child: AutoRouter()),
        ],
      ),
    );
  }
}
