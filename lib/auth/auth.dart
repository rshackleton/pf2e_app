import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pf2e_app/auth/auth_service.dart';
import 'package:pf2e_app/auth/login.dart';
import 'package:pf2e_app/auth/profile.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  AuthState createState() => AuthState();
}

class AuthState extends State<Auth> {
  bool isBusy = true;
  String errorMessage = "";
  Credentials? _credentials;

  @override
  void initState() {
    super.initState();
    initAction();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isBusy
          ? const CircularProgressIndicator.adaptive()
          : _credentials != null
          ? Profile(logoutAction, _credentials?.user)
          : Login(loginAction, errorMessage),
    );
  }

  Future<void> initAction() async {
    setState(() {
      isBusy = true;
      errorMessage = "";
    });

    try {
      final hasSession = await AuthService().hasSession();

      if (!hasSession) {
        setState(() {
          isBusy = false;
          _credentials = null;
        });
        return;
      }

      final credentials = await AuthService().session();

      setState(() {
        isBusy = false;
        _credentials = credentials;
      });
    } on Exception catch (e, s) {
      debugPrint('init error: $e - stack: $s');

      setState(() {
        isBusy = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = "";
    });

    try {
      final credentials = await AuthService().login();

      setState(() {
        isBusy = false;
        _credentials = credentials;
      });
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logoutAction() async {
    setState(() {
      isBusy = true;
      errorMessage = "";
    });

    try {
      await AuthService().logout();

      setState(() {
        isBusy = false;
        _credentials = null;
      });
    } on Exception catch (e, s) {
      debugPrint('logout error: $e - stack: $s');

      setState(() {
        isBusy = false;
        errorMessage = e.toString();
      });
    }
  }
}
