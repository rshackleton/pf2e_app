import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/widgets/adventures_list_widget.dart';
import 'package:pf2e_app/features/home/widget/home_widget.dart';
import 'package:watch_it/watch_it.dart';

@RoutePage()
class AdventuresPage extends WatchingWidget {
  const AdventuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adventures'), actions: [HomeWidget()]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Adventures Page'), AdventuresListWidget()],
        ),
      ),
    );
  }
}
