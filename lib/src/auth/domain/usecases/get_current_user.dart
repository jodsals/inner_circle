import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Execute the use case
  /// Returns null if no user is authenticated
  Future<Either<Failure, User?>> execute() async {
    return await _repository.getCurrentUser();
  }
}
