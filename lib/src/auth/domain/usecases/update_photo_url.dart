import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user photo URL
class UpdatePhotoUrlUseCase {
  final AuthRepository _repository;

  UpdatePhotoUrlUseCase(this._repository);

  /// Execute the photo URL update use case
  Future<Either<Failure, void>> execute(String photoUrl) async {
    if (photoUrl.trim().isEmpty) {
      return Left(ValidationFailure('Foto-URL darf nicht leer sein'));
    }

    return await _repository.updatePhotoUrl(photoUrl.trim());
  }
}
