import 'package:flutter/material.dart';
import 'package:pf2e_app/features/auth/manager/adventure_manager.dart';
import 'package:watch_it/watch_it.dart';

class AdventuresPage extends WatchingWidget {
  const AdventuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adventureManager = di<AdventureManager>();

    // Initialize auth on first build
    callOnce((context) {
      adventureManager.getAdventuresCommand.run();
    });

    // Watch the initialization state
    final isFetching = watchValue(
      (AdventureManager m) => m.getAdventuresCommand.isRunning,
    );

    // Watch credentials
    final adventures = watchValue((AdventureManager m) => m.adventures);

    if (isFetching) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Center(
            child: const Text(
              'Adventures',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: adventures.length,
            itemBuilder: (context, index) {
              final adventure = adventures[index];
              return ListTile(
                key: ValueKey(adventure.id),
                title: Text(adventure.name),
                onTap: () => {
                  debugPrint(
                    'Tapped on adventure: ${adventure.id} ${adventure.name}',
                  ),
                },
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Adventure'),
            onPressed: () => adventureManager.createAdventureCommand.run(),
          ),
        ],
      ),
    );
  }
}
