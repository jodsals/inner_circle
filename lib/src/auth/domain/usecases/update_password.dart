import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user password
class UpdatePasswordUseCase {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  /// Execute the password update use case
  /// Validates new password before updating
  Future<Either<Failure, void>> execute(String newPassword) async {
    // Validate password
    final passwordError = Validators.validatePassword(newPassword);
    if (passwordError != null) {
      return Left(ValidationFailure(passwordError));
    }

    return await _repository.updatePassword(newPassword);
  }
}
