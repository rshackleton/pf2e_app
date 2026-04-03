import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
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
        ? Center(child: CircularProgressIndicator.adaptive())
        : ListView.builder(
            itemBuilder: (context, index) {
              final adventure = adventures[index];
              return ListTile(
                onTap: () => {
                  context.router.push(
                    AdventureDetailRoute(adventure: adventure),
                  ),
                },
                title: Text(adventure.name),
                trailing: IconButton(
                  onPressed: () => {
                    debugPrint('More options for ${adventure.name}'),
                  },
                  icon: Icon(Icons.adaptive.more),
                ),
              );
            },
            itemCount: adventures.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          );
  }
}
