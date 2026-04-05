import 'package:auth0_flutter/auth0_flutter.dart';

abstract class AuthService {
  Future<Credentials?> login();
  Future<void> logout();
  Future<Credentials?> getSession();
}
