import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Authentication state
///
/// Represents all possible authentication states in the app
@freezed
class AuthState with _$AuthState {
  /// Initial state (checking authentication)
  const factory AuthState.initial() = _Initial;

  /// Loading state (login in progress)
  const factory AuthState.loading() = _Loading;

  /// Authenticated state (user logged in)
  const factory AuthState.authenticated({
    required User user,
    required Session session,
    @Default(false) bool isStale,
    @Default(false) bool isOffline,
  }) = _Authenticated;

  /// Unauthenticated state (user not logged in)
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Error state (login failed)
  const factory AuthState.error({
    required String message,
    String? code,
  }) = _Error;

  /// Session expired state (needs re-login)
  const factory AuthState.sessionExpired() = _SessionExpired;
}
