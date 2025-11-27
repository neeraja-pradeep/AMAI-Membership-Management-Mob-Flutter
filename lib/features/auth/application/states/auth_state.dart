import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';

/// Authentication state
///
/// Represents all possible authentication states in the app
sealed class AuthState {
  const AuthState();
}

/// Initial state (checking authentication)
final class AuthStateInitial extends AuthState {
  const AuthStateInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthStateInitial;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'AuthState.initial()';
}

/// Loading state (login in progress)
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthStateLoading;

  @override
  int get hashCode => 1;

  @override
  String toString() => 'AuthState.loading()';
}

/// Authenticated state (user logged in)
final class AuthStateAuthenticated extends AuthState {
  final User user;
  final Session session;
  final bool isStale;
  final bool isOffline;

  const AuthStateAuthenticated({
    required this.user,
    required this.session,
    this.isStale = false,
    this.isOffline = false,
  });

  AuthStateAuthenticated copyWith({
    User? user,
    Session? session,
    bool? isStale,
    bool? isOffline,
  }) {
    return AuthStateAuthenticated(
      user: user ?? this.user,
      session: session ?? this.session,
      isStale: isStale ?? this.isStale,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          session == other.session &&
          isStale == other.isStale &&
          isOffline == other.isOffline;

  @override
  int get hashCode =>
      user.hashCode ^ session.hashCode ^ isStale.hashCode ^ isOffline.hashCode;

  @override
  String toString() {
    return 'AuthState.authenticated(user: ${user.email}, session: ${session.isValid ? "valid" : "expired"}, isStale: $isStale, isOffline: $isOffline)';
  }
}

/// Unauthenticated state (user not logged in)
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthStateUnauthenticated;

  @override
  int get hashCode => 2;

  @override
  String toString() => 'AuthState.unauthenticated()';
}

/// Error state (login failed)
final class AuthStateError extends AuthState {
  final String message;
  final String? code;
  final Map<String, String>? fieldErrors;
  final int? attemptCount;
  final int? retryAfter;

  const AuthStateError({
    required this.message,
    this.code,
    this.fieldErrors,
    this.attemptCount,
    this.retryAfter,
  });

  /// Check if account is locked out (5+ failed attempts)
  bool get isLockedOut => (attemptCount ?? 0) >= 5;

  /// Check if rate limited (429 error)
  bool get isRateLimited => retryAfter != null && retryAfter! > 0;

  /// Get error for specific field
  String? getFieldError(String fieldName) {
    return fieldErrors?[fieldName];
  }

  AuthStateError copyWith({
    String? message,
    String? code,
    Map<String, String>? fieldErrors,
    int? attemptCount,
    int? retryAfter,
  }) {
    return AuthStateError(
      message: message ?? this.message,
      code: code ?? this.code,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      attemptCount: attemptCount ?? this.attemptCount,
      retryAfter: retryAfter ?? this.retryAfter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          attemptCount == other.attemptCount &&
          retryAfter == other.retryAfter;

  @override
  int get hashCode =>
      message.hashCode ^
      code.hashCode ^
      (attemptCount ?? 0).hashCode ^
      (retryAfter ?? 0).hashCode;

  @override
  String toString() =>
      'AuthState.error(message: $message, code: $code, attemptCount: $attemptCount, retryAfter: $retryAfter)';
}

/// Session expired state (needs re-login)
final class AuthStateSessionExpired extends AuthState {
  const AuthStateSessionExpired();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthStateSessionExpired;

  @override
  int get hashCode => 3;

  @override
  String toString() => 'AuthState.sessionExpired()';
}
