import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/router.gr.dart';

class NewAdventureButton extends StatelessWidget {
  const NewAdventureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        context.router.push(const NewAdventureRoute());
      },
    );
  }
}
