import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out the current user
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute the logout use case
  Future<Either<Failure, void>> execute() async {
    return await _repository.logout();
  }
}
