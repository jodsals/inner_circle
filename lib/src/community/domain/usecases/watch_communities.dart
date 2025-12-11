import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community.dart';
import '../repositories/community_repository.dart';

/// Use case for watching communities stream
class WatchCommunitiesUseCase {
  final CommunityRepository repository;

  WatchCommunitiesUseCase(this.repository);

  Stream<Either<Failure, List<Community>>> call() {
    return repository.watchCommunities();
  }
}