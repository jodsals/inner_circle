import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new user with email and password
class RegisterWithEmailUseCase {
  final AuthRepository _repository;

  RegisterWithEmailUseCase(this._repository);

  /// Execute the registration use case
  /// Validates input and delegates to repository
  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
    String? displayName,
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
    return await _repository.registerWithEmail(
      email: email.trim(),
      password: password,
      displayName: displayName?.trim(),
    );
  }
}
