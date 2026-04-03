import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/home/widget/home_widget.dart';

@RoutePage()
class AdventureDetailPage extends StatelessWidget {
  final Adventure adventure;

  const AdventureDetailPage({super.key, required this.adventure});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(adventure.name), actions: [HomeWidget()]),
      body: Center(child: Text(adventure.createdAt.toString())),
    );
  }
}
