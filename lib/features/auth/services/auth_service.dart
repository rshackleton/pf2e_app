import 'package:auth0_flutter/auth0_flutter.dart';

/// Abstract interface for authentication service.
/// Implementations handle authentication with different providers.
abstract class AuthService {
  /// Attempt to log in the user.
  Future<Credentials?> login();

  /// Log out the current user.
  Future<void> logout();

  /// Retrieve the current session credentials.
  Future<Credentials> getSession();

  /// Check if valid credentials are available.
  Future<bool> hasValidCredentials();
}
