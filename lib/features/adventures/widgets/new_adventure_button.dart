import 'package:flutter/material.dart';
import 'package:pf2e_app/features/adventures/manager/adventure_manager.dart';
import 'package:pf2e_app/locator.dart';

class NewAdventureButton extends StatelessWidget {
  const NewAdventureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => NewAdventureDialog(),
        );
      },
    );
  }
}

class NewAdventureDialog extends StatelessWidget {
  const NewAdventureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        child: Material(
          borderRadius: BorderRadius.circular(4),
          elevation: 8,
          type: MaterialType.canvas,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: NewAdventureForm(),
          ),
        ),
      ),
    );
  }
}

class NewAdventureForm extends StatefulWidget {
  const NewAdventureForm({super.key});

  @override
  State<NewAdventureForm> createState() => _NewAdventureFormState();
}

class _NewAdventureFormState extends State<NewAdventureForm> {
  late TextEditingController _controller;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text('Create New Adventure', style: TextStyle(fontSize: 16)),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Adventure Name'),
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
                flex: 1,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
              Expanded(
                flex: 1,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      di<AdventureManager>().createAdventureCommand.run(
                        _controller.value.text,
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
