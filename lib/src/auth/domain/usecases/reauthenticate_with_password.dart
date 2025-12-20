import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for reauthenticating user with password
class ReauthenticateWithPasswordUseCase {
  final AuthRepository _repository;

  ReauthenticateWithPasswordUseCase(this._repository);

  /// Execute the reauthentication use case
  Future<Either<Failure, void>> execute(String password) async {
    if (password.isEmpty) {
      return Left(ValidationFailure('Passwort darf nicht leer sein'));
    }

    return await _repository.reauthenticateWithPassword(password);
  }
}
