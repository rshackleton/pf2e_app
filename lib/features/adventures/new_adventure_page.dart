import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/locator.dart';

@RoutePage()
class NewAdventurePage extends StatefulWidget {
  const NewAdventurePage({super.key});

  @override
  State<NewAdventurePage> createState() => _NewAdventurePageState();
}

class _NewAdventurePageState extends State<NewAdventurePage> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Adventure')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Adventure Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the adventure name.';
                  }

                  return null;
                },
              ),
              Flex(
                direction: Axis.horizontal,
                spacing: 16,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.router.maybePop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          di<AdventureManager>().createAdventureCommand.run(
                            _controller.text,
                          );
                          context.router.maybePop();
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
