import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/auth_exception.dart';
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
       super(const AuthStateInitial()) {
    // Check authentication on initialization
    checkAuthentication();
  }

  /// Check if user is authenticated
  ///
  /// SCENARIO 2: App Restart with Internet (12h old cache)
  /// SCENARIO 3: App Restart No Internet (12h old cache)
  Future<void> checkAuthentication() async {
    state = const AuthStateInitial();

    try {
      final result = await _checkAuthUseCase.execute();

      if (result.isAuthenticated &&
          result.user != null &&
          result.session != null) {
        // Check if session is expiring soon or stale
        final isStale = result.session!.isExpiringSoon;

        state = AuthStateAuthenticated(
          user: result.user!,
          session: result.session!,
          isStale: isStale,
        );
      } else {
        state = const AuthStateUnauthenticated();
      }
    } catch (e) {
      state = const AuthStateUnauthenticated();
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
    state = const AuthStateLoading();

    try {
      final result = await _loginUseCase.execute(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      state = AuthStateAuthenticated(
        user: result.user,
        session: result.session,
      );
    } on AuthException catch (e) {
      // Extract metadata from specific exception types
      state = AuthStateError(
        message: e.message,
        code: e.code,
        fieldErrors: e.fieldErrors,
        attemptCount: e is UnauthorizedException ? e.attemptCount : null,
        retryAfter: e is TooManyRequestsException ? e.retryAfter : null,
      );
    } catch (e) {
      state = AuthStateError(
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Logout current user
  ///
  /// CACHE INVALIDATION: User logout  Delete ALL auth_* keys
  /// CACHE INVALIDATION: User logout → Delete ALL auth_* keys
  Future<void> logout() async {
    try {
      await _logoutUseCase.execute();
      state = const AuthStateUnauthenticated();
    } catch (e) {
      // Even if logout fails, transition to unauthenticated
      state = const AuthStateUnauthenticated();
    }
  }

  /// Mark session as expired
  void markSessionExpired() {
    state = const AuthStateSessionExpired();
  }

  /// Mark as offline
  void markOffline() {
    if (state case AuthStateAuthenticated(
      :final user,
      :final session,
      :final isStale,
    )) {
      state = AuthStateAuthenticated(
        user: user,
        session: session,
        isStale: isStale,
        isOffline: true,
      );
    }
  }

  /// Mark as online
  void markOnline() {
    if (state case AuthStateAuthenticated(
      :final user,
      :final session,
      :final isStale,
    )) {
      state = AuthStateAuthenticated(
        user: user,
        session: session,
        isStale: isStale,
        isOffline: false,
      );
    }
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
  return switch (authState) {
    AuthStateAuthenticated(:final user) => user,
    _ => null,
  };
});

/// Convenience provider for current session
final currentSessionProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthStateAuthenticated(:final session) => session,
    _ => null,
  };
});

/// Convenience provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthStateAuthenticated;
});

/// Convenience provider for offline status
final isOfflineProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthStateAuthenticated(:final isOffline) => isOffline,
    _ => false,
  };
});

/// Convenience provider for stale data warning
final isStaleProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthStateAuthenticated(:final isStale) => isStale,
    _ => false,
  };
});
