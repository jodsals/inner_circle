import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community.dart';
import '../repositories/community_repository.dart';

/// Use case for getting all communities
class GetCommunitiesUseCase {
  final CommunityRepository repository;

  GetCommunitiesUseCase(this.repository);

  Future<Either<Failure, List<Community>>> call() async {
    return await repository.getCommunities();
  }
}