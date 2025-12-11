import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/forum.dart';
import '../repositories/forum_repository.dart';

/// Use case for updating a forum
class UpdateForumUseCase {
  final ForumRepository repository;

  UpdateForumUseCase(this.repository);

  Future<Either<Failure, Forum>> call({
    required String communityId,
    required String forumId,
    required String title,
  }) async {
    // Validate inputs
    if (communityId.trim().isEmpty) {
      return const Left(ValidationFailure('Community ID cannot be empty'));
    }

    if (forumId.trim().isEmpty) {
      return const Left(ValidationFailure('Forum ID cannot be empty'));
    }

    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }

    return await repository.updateForum(
      communityId: communityId.trim(),
      forumId: forumId.trim(),
      title: title.trim(),
    );
  }
}