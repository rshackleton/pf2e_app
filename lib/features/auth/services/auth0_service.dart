import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Wraps the Auth0 library for dependency injection.
/// Converts Auth0-specific data to app types.
class Auth0Service {
  late final Auth0 _auth0;
  late final String _appScheme;

  /// Initialize Auth0 with environment variables.
  Future<Auth0Service> init() async {
    _auth0 = Auth0(dotenv.get('AUTH0_DOMAIN'), dotenv.get('AUTH0_CLIENT_ID'));
    _appScheme = dotenv.get("AUTH0_SCHEME");
    return this;
  }

  Future<Credentials?> login() async {
    final credentials = await _auth0
        .webAuthentication(scheme: _appScheme)
        .login(useHTTPS: true);
    return credentials;
  }

  Future<void> logout() async {
    await _auth0.webAuthentication(scheme: _appScheme).logout(useHTTPS: true);
  }

  Future<Credentials> getSession() async {
    return await _auth0.credentialsManager.credentials();
  }

  Future<bool> hasValidCredentials() async {
    return await _auth0.credentialsManager.hasValidCredentials();
  }
}
