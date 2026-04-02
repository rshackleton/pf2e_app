import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final UserProfile? user;

  const Profile(this.logoutAction, this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hello, ${user?.name ?? "User"}!"),
        ElevatedButton(onPressed: logoutAction, child: Text("Logout")),
      ],
    );
  }
}
