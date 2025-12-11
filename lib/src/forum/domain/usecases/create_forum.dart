import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/forum.dart';
import '../repositories/forum_repository.dart';

/// Use case for creating a forum
class CreateForumUseCase {
  final ForumRepository repository;

  CreateForumUseCase(this.repository);

  Future<Either<Failure, Forum>> call({
    required String communityId,
    required String title,
  }) async {
    // Validate inputs
    if (communityId.trim().isEmpty) {
      return const Left(ValidationFailure('Community ID cannot be empty'));
    }

    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }

    return await repository.createForum(
      communityId: communityId.trim(),
      title: title.trim(),
    );
  }
}