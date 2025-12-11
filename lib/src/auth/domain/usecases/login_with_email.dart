import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in with email and password
/// Encapsulates the business logic for email/password authentication
class LoginWithEmailUseCase {
  final AuthRepository _repository;

  LoginWithEmailUseCase(this._repository);

  /// Execute the login use case
  /// Validates input and delegates to repository
  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
  }) async {
    // Validate email
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Left(ValidationFailure(emailError));
    }

    // Validate password
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      return Left(ValidationFailure(passwordError));
    }

    // Delegate to repository
    return await _repository.loginWithEmail(
      email: email.trim(),
      password: password,
    );
  }
}
