import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';

/// Manages authentication business logic and state.
/// Provides reactive Commands and ValueListenables for the UI.
class AuthManager extends ChangeNotifier {
  final _authService = di<AuthService>();

  // State
  final _credentials = ValueNotifier<Credentials?>(null);
  final _authError = ValueNotifier<String?>(null);

  ValueListenable<Credentials?> get credentials => _credentials;
  ValueListenable<String?> get authError => _authError;

  late final initCommand = Command.createAsyncNoParamNoResult(
    _init,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final loginCommand = Command.createAsyncNoParamNoResult(
    _login,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final logoutCommand = Command.createAsyncNoParamNoResult(
    _logout,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  Future<void> _init() async {
    _authError.value = null;

    final hasSession = await _authService.hasValidCredentials();

    if (!hasSession) {
      _credentials.value = null;
      return;
    }

    final credentials = await _authService.getSession();
    _credentials.value = credentials;
  }

  Future<void> _login() async {
    _authError.value = null;

    final credentials = await _authService.login();
    _credentials.value = credentials;
  }

  Future<void> _logout() async {
    _authError.value = null;

    await _authService.logout();
    _credentials.value = null;
  }

  @override
  void dispose() {
    _credentials.dispose();
    _authError.dispose();
    initCommand.dispose();
    loginCommand.dispose();
    logoutCommand.dispose();
    super.dispose();
  }
}
