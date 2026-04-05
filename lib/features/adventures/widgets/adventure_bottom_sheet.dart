import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/locator.dart';
import 'package:pf2e_app/router.gr.dart';

class AdventureBottomSheet extends StatelessWidget {
  final Adventure adventure;

  const AdventureBottomSheet({super.key, required this.adventure});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text('View'),
          onTap: () {
            Navigator.pop(context);
            context.router.navigate(
              AdventureDetailRootRoute(adventureId: adventure.id),
            );
          },
        ),
        ListTile(
          title: Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            di<AdventureManager>().deleteAdventureCommand.run(adventure.id);
          },
        ),
      ],
    );
  }
}
