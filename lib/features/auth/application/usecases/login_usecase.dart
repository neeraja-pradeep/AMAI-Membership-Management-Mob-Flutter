import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Login use case
///
/// Handles user login with email and password
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login
  ///
  /// Returns user ID on success, null if user data not in response
  /// Throws exception on failure
  Future<int?> execute({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Call repository - returns user ID
    return await _repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }
}
