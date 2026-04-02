import 'package:flutter/material.dart';

class LoginWidget extends StatelessWidget {
  final VoidCallback onLogin;
  final String? error;

  const LoginWidget({required this.onLogin, this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: onLogin, child: const Text("Login")),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
