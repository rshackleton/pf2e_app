import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';

class AuthManager extends ChangeNotifier {
  final _authService = di<AuthService>();

  final _credentials = ValueNotifier<Credentials?>(null);

  ValueListenable<Credentials?> get credentials => _credentials;

  late final initCommand = Command.createAsyncNoParamNoResult(
    _init,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  Future<void> _init() async {
    _credentials.value = await _authService.getSession();
  }

  late final loginCommand = Command.createAsyncNoParam<Credentials?>(
    _login,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
    initialValue: null,
  );

  Future<Credentials?> _login() async {
    final credentials = await _authService.login();
    _credentials.value = credentials;
    return credentials;
  }

  late final logoutCommand = Command.createAsyncNoParamNoResult(
    _logout,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  Future<void> _logout() async {
    await _authService.logout();
    _credentials.value = null;
  }

  @override
  void dispose() {
    _credentials.dispose();
    initCommand.dispose();
    loginCommand.dispose();
    logoutCommand.dispose();
    super.dispose();
  }
}
