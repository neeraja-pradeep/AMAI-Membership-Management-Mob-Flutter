import '../../domain/repositories/auth_repository.dart';

/// Logout use case
///
/// Handles user logout and session cleanup
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout
  ///
  /// Clears all session data and cache
  Future<void> execute() async {
    await _repository.logout();
  }
}
