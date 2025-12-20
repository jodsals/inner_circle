import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for deleting user account
class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  /// Execute the account deletion use case
  Future<Either<Failure, void>> execute() async {
    return await _repository.deleteAccount();
  }
}
