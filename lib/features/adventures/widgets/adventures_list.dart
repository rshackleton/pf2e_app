import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/widgets/adventure_bottom_sheet.dart';
import 'package:pf2e_app/router.gr.dart';
import 'package:watch_it/watch_it.dart';

class AdventuresListWidget extends WatchingWidget {
  const AdventuresListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adventureManager = di<AdventureManager>();

    callOnce((context) {
      adventureManager.getAdventuresCommand.run();
    });

    final isFetching = watchValue(
      (AdventureManager m) => m.getAdventuresCommand.isRunning,
    );

    final adventures = watchValue((AdventureManager m) => m.adventures);

    return isFetching
        ? SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        : SliverList.builder(
            itemBuilder: (context, index) {
              final adventure = adventures[index];
              return ListTile(
                onTap: () => {
                  context.router.navigate(
                    AdventureDetailRootRoute(adventureId: adventure.id),
                  ),
                },
                title: Text(adventure.name),
                trailing: IconButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) =>
                        AdventureBottomSheet(adventure: adventure),
                  ),
                  icon: Icon(Icons.adaptive.more),
                ),
              );
            },
            itemCount: adventures.length,
          );
  }
}
