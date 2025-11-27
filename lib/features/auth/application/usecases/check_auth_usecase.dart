import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Check authentication use case
///
/// Checks if user is authenticated and returns current user/session
class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  /// Execute authentication check
  ///
  /// Returns User and Session if authenticated, null otherwise
  Future<({User? user, Session? session, bool isAuthenticated})> execute() async {
    final isAuthenticated = await _repository.isAuthenticated();

    if (!isAuthenticated) {
      return (user: null, session: null, isAuthenticated: false);
    }

    final user = await _repository.getCurrentUser();
    final session = await _repository.getCurrentSession();

    return (user: user, session: session, isAuthenticated: true);
  }
}
