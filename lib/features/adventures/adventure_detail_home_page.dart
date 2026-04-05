import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class AdventureDetailHomePage extends WatchingWidget {
  final int adventureId;

  const AdventureDetailHomePage({
    super.key,
    @PathParam.inherit() required this.adventureId,
  });

  @override
  Widget build(BuildContext context) {
    final isFetching = watchValue(
      (AdventureManager m) => m.getAdventureCommand.isRunning,
    );

    final adventure = watchValue((AdventureManager m) => m.adventure);

    if (isFetching) {
      return CircularProgressIndicator.adaptive();
    }

    if (adventure == null) {
      return SizedBox();
    }

    return Column(
      children: [
        Text("Created at: ${DateFormat.yMMMd().format(adventure.createdAt)}"),
      ],
    );
  }
}
