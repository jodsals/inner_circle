import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community.dart';
import '../repositories/community_repository.dart';

/// Use case for creating a community
class CreateCommunityUseCase {
  final CommunityRepository repository;

  CreateCommunityUseCase(this.repository);

  Future<Either<Failure, Community>> call({
    required String title,
    required String description,
    String? bannerImagePath,
  }) async {
    // Validate inputs
    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }

    if (description.trim().isEmpty) {
      return const Left(ValidationFailure('Description cannot be empty'));
    }

    return await repository.createCommunity(
      title: title.trim(),
      description: description.trim(),
      bannerImagePath: bannerImagePath,
    );
  }
}