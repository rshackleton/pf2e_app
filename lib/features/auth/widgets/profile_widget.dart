import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final VoidCallback onLogout;
  final UserProfile? user;

  const ProfileWidget({required this.onLogout, this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            children: [
              if (user?.pictureUrl != null)
                CircleAvatar(
                  radius: 96,
                  backgroundImage: NetworkImage(user!.pictureUrl.toString()),
                ),
              const SizedBox(height: 16),
              Text(
                "Welcome!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onLogout, child: const Text("Logout")),
      ],
    );
  }
}
