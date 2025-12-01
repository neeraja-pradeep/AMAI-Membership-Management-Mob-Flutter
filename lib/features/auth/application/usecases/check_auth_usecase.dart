import '../../domain/repositories/auth_repository.dart';

/// Use case that checks if the user is authenticated.
class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  /// Returns `true` if user is logged in, otherwise `false`.
  Future<bool> execute() async {
    return await _repository.isAuthenticated();
  }
}
