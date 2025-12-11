import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community.dart';
import '../repositories/community_repository.dart';

/// Use case for updating a community
class UpdateCommunityUseCase {
  final CommunityRepository repository;

  UpdateCommunityUseCase(this.repository);

  Future<Either<Failure, Community>> call({
    required String id,
    String? title,
    String? description,
    String? bannerImagePath,
  }) async {
    // Validate inputs
    if (title != null && title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }

    if (description != null && description.trim().isEmpty) {
      return const Left(ValidationFailure('Description cannot be empty'));
    }

    return await repository.updateCommunity(
      id: id,
      title: title?.trim(),
      description: description?.trim(),
      bannerImagePath: bannerImagePath,
    );
  }
}