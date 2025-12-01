sealed class AuthState {
  const AuthState();
}

/// App is starting / checking saved login flag
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Login request in progress
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// User successfully authenticated
class AuthStateAuthenticated extends AuthState {
  final bool isLoggedIn;

  const AuthStateAuthenticated({this.isLoggedIn = true});
}

/// User logged out / not logged in
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Login failed
class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
