import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories/auth_repository_provider.dart';
import '../states/auth_state.dart';
import '../usecases/check_auth_usecase.dart';
import '../usecases/login_usecase.dart';
import '../usecases/logout_usecase.dart';

/// Auth state notifier
///
/// Manages authentication state for the entire app
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
       super(const AuthState.initial()) {
    // Check authentication on initialization
    checkAuthentication();
  }

  /// Check if user is authenticated
  ///
  /// SCENARIO 2: App Restart with Internet (12h old cache)
  /// SCENARIO 3: App Restart No Internet (12h old cache)
  Future<void> checkAuthentication() async {
    state = const AuthState.initial();

    try {
      final result = await _checkAuthUseCase.execute();

      if (result.isAuthenticated &&
          result.user != null &&
          result.session != null) {
        // Check if session is expiring soon or stale
        final isStale = result.session!.isExpiringSoon;

        state = AuthState.authenticated(
          user: result.user!,
          session: result.session!,
          isStale: isStale,
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  ///
  /// SCENARIO 1: First Launch (No Cache)
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AuthState.loading();

    try {
      final result = await _loginUseCase.execute(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      state = AuthState.authenticated(
        user: result.user,
        session: result.session,
      );
    } catch (e) {
      state = AuthState.error(
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Logout current user
  ///
  /// CACHE INVALIDATION: User logout  Delete ALL auth_* keys
  Future<void> logout() async {
    try {
      await _logoutUseCase.execute();
      state = const AuthState.unauthenticated();
    } catch (e) {
      // Even if logout fails, transition to unauthenticated
      state = const AuthState.unauthenticated();
    }
  }

  /// Mark session as expired
  void markSessionExpired() {
    state = const AuthState.sessionExpired();
  }

  /// Mark as offline
  void markOffline() {
    state.whenOrNull(
      authenticated: (user, session, isStale, _) {
        state = AuthState.authenticated(
          user: user,
          session: session,
          isStale: isStale,
          isOffline: true,
        );
      },
    );
  }

  /// Mark as online
  void markOnline() {
    state.whenOrNull(
      authenticated: (user, session, isStale, _) {
        state = AuthState.authenticated(
          user: user,
          session: session,
          isStale: isStale,
          isOffline: false,
        );
      },
    );
  }
}

/// Auth provider (global state)
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// final authNotifier = ref.read(authProvider.notifier);
/// ```
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return AuthStateNotifier(
    loginUseCase: LoginUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    checkAuthUseCase: CheckAuthUseCase(repository),
  );
});

/// Convenience provider for current user
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.whenOrNull(authenticated: (user, _, __, ___) => user);
});

/// Convenience provider for current session
final currentSessionProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.whenOrNull(authenticated: (_, session, __, ___) => session);
});

/// Convenience provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_, __, ___, ____) => true,
    orElse: () => false,
  );
});

/// Convenience provider for offline status
final isOfflineProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_, __, ___, isOffline) => isOffline,
    orElse: () => false,
  );
});

/// Convenience provider for stale data warning
final isStaleProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_, __, isStale, ___) => isStale,
    orElse: () => false,
  );
});
