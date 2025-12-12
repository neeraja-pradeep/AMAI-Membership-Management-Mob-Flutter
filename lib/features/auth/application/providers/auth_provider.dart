import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/auth_exception.dart';
import '../../infrastructure/repositories/auth_repository_provider.dart';
import '../states/auth_state.dart';
import '../usecases/check_auth_usecase.dart';
import '../usecases/login_usecase.dart';
import '../usecases/logout_usecase.dart';
import '../../../home/application/providers/home_providers.dart';
import '../../../profile/application/providers/profile_providers.dart';

/// Auth state notifier
/// Controls authentication for the whole app.
class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final Ref _ref;

  AuthStateNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required Ref ref,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        _ref = ref,
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
      final userId = await _loginUseCase.execute(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      // Login successful if we get here (no exception thrown)
      // userId may be null if API doesn't return user data, but login still succeeded
      state = AuthStateAuthenticated(userId: userId);
    } on AuthException catch (e) {
      state = AuthStateError(e.message);
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  /// Logout request
  Future<void> logout() async {
    await _logoutUseCase.execute();

    // Set auth state to unauthenticated FIRST to trigger navigation
    state = const AuthStateUnauthenticated();

    // Clear all feature state providers AFTER navigation starts
    // Delay to allow navigation to complete and widgets to unmount
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _ref.read(membershipStateProvider.notifier).clear();
      await _ref.read(aswasStateProvider.notifier).clear();
      await _ref.read(eventsStateProvider.notifier).clear();
      await _ref.read(announcementsStateProvider.notifier).clear();
      await _ref.read(nomineesStateProvider.notifier).clear();
      _ref.read(profileStateProvider.notifier).clear();
    });
  }
}

/// PROVIDERS
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);

  return AuthStateNotifier(
    loginUseCase: LoginUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    checkAuthUseCase: CheckAuthUseCase(repo),
    ref: ref,
  );
});

/// Convenience provider — returns `true` if logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth is AuthStateAuthenticated;
});

/// Provider for the authenticated user's ID from login response
/// Returns null if not authenticated or if user ID was not in the login response
final authUserIdProvider = Provider<int?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is AuthStateAuthenticated) {
    return auth.userId;
  }
  return null;
});
