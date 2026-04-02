import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pf2e_app/features/auth/services/auth0_service.dart';

final di = GetIt.instance;

/// Manages authentication business logic and state.
/// Provides reactive Commands and ValueListenables for the UI.
class AuthManager extends ChangeNotifier {
  final _auth0Service = di<Auth0Service>();

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

    final hasSession = await _auth0Service.hasValidCredentials();

    if (!hasSession) {
      _credentials.value = null;
      return;
    }

    final credentials = await _auth0Service.getSession();
    _credentials.value = credentials;
  }

  Future<void> _login() async {
    _authError.value = null;

    final credentials = await _auth0Service.login();
    _credentials.value = credentials;
  }

  Future<void> _logout() async {
    _authError.value = null;

    await _auth0Service.logout();
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
