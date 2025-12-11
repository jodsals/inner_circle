import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/forum_repository.dart';

/// Use case for deleting a forum
class DeleteForumUseCase {
  final ForumRepository repository;

  DeleteForumUseCase(this.repository);

  Future<Either<Failure, void>> call(String communityId, String forumId) async {
    if (communityId.trim().isEmpty) {
      return const Left(ValidationFailure('Community ID cannot be empty'));
    }

    if (forumId.trim().isEmpty) {
      return const Left(ValidationFailure('Forum ID cannot be empty'));
    }

    return await repository.deleteForum(communityId, forumId);
  }
}