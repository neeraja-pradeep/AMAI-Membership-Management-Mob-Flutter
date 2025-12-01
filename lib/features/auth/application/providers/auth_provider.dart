import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/auth_exception.dart';
import '../../infrastructure/repositories/auth_repository_provider.dart';
import '../states/auth_state.dart';
import '../usecases/check_auth_usecase.dart';
import '../usecases/login_usecase.dart';
import '../usecases/logout_usecase.dart';

/// Auth state notifier
/// Controls authentication for the whole app.
class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;

  AuthStateNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthUseCase = checkAuthUseCase,
       super(const AuthStateInitial()) {
    checkAuthentication();
  }

  /// On app start: check if user was already logged in.
  Future<void> checkAuthentication() async {
    state = const AuthStateInitial();

    try {
      final isLoggedIn = await _checkAuthUseCase.execute();

      if (isLoggedIn) {
        state = const AuthStateAuthenticated();
      } else {
        state = const AuthStateUnauthenticated();
      }
    } catch (_) {
      state = const AuthStateUnauthenticated();
    }
  }

  /// Login request
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AuthStateLoading();

    try {
      final success = await _loginUseCase.execute(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (success) {
        state = const AuthStateAuthenticated();
      } else {
        state = const AuthStateError("Login failed.");
      }
    } on AuthException catch (e) {
      state = AuthStateError(e.message);
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  /// Logout request
  Future<void> logout() async {
    await _logoutUseCase.execute();
    state = const AuthStateUnauthenticated();
  }
}

/// PROVIDERS
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);

  return AuthStateNotifier(
    loginUseCase: LoginUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    checkAuthUseCase: CheckAuthUseCase(repo),
  );
});

/// Convenience provider — returns `true` if logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth is AuthStateAuthenticated;
});
