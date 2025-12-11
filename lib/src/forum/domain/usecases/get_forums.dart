import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/forum.dart';
import '../repositories/forum_repository.dart';

/// Use case for getting all forums for a community
class GetForumsUseCase {
  final ForumRepository repository;

  GetForumsUseCase(this.repository);

  Future<Either<Failure, List<Forum>>> call(String communityId) async {
    if (communityId.trim().isEmpty) {
      return const Left(ValidationFailure('Community ID cannot be empty'));
    }

    return await repository.getForums(communityId);
  }
}