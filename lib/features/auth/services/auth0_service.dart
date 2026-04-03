import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';

class Auth0Service implements AuthService {
  late final Auth0 _auth0;
  late final String _appScheme;

  Future<Auth0Service> init() async {
    _auth0 = Auth0(dotenv.get('AUTH0_DOMAIN'), dotenv.get('AUTH0_CLIENT_ID'));
    _appScheme = dotenv.get("AUTH0_SCHEME");
    return this;
  }

  @override
  Future<Credentials?> login() async {
    try {
      final credentials = await _auth0
          .webAuthentication(scheme: _appScheme)
          .login(useHTTPS: true);

      return credentials;
    } catch (e) {
      debugPrint("Login failed: $e");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: _appScheme).logout(useHTTPS: true);
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }

  @override
  Future<Credentials?> getSession() async {
    try {
      return await _auth0.credentialsManager.credentials();
    } catch (e) {
      debugPrint("Get credentials failed: $e");
      return null;
    }
  }
}
