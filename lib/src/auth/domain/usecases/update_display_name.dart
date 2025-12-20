import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user display name
class UpdateDisplayNameUseCase {
  final AuthRepository _repository;

  UpdateDisplayNameUseCase(this._repository);

  /// Execute the display name update use case
  /// Validates display name before updating
  Future<Either<Failure, void>> execute(String displayName) async {
    // Validate display name
    final displayNameError = Validators.validateRequired(displayName, 'Anzeigename');
    if (displayNameError != null) {
      return Left(ValidationFailure(displayNameError));
    }

    return await _repository.updateDisplayName(displayName.trim());
  }
}
