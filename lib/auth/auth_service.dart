import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _auth0 = Auth0(
    dotenv.get('AUTH0_DOMAIN'),
    dotenv.get('AUTH0_CLIENT_ID'),
  );

  final _appScheme = dotenv.get("AUTH0_SCHEME");

  Future<Credentials?> login() async {
    final credentials = await _auth0
        .webAuthentication(scheme: _appScheme)
        .login(useHTTPS: true);

    return credentials;
  }

  Future<void> logout() async {
    await _auth0.webAuthentication(scheme: _appScheme).logout(useHTTPS: true);
  }

  Future<Credentials> session() async {
    final credentials = await _auth0.credentialsManager.credentials();
    return credentials;
  }

  Future<bool> hasSession() async {
    final hasSession = await _auth0.credentialsManager.hasValidCredentials();
    return hasSession;
  }
}
