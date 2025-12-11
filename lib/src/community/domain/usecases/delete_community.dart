import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/community_repository.dart';

/// Use case for deleting a community
class DeleteCommunityUseCase {
  final CommunityRepository repository;

  DeleteCommunityUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Community ID cannot be empty'));
    }

    return await repository.deleteCommunity(id);
  }
}