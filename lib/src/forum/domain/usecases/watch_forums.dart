import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/forum.dart';
import '../repositories/forum_repository.dart';

/// Use case for watching forums stream
class WatchForumsUseCase {
  final ForumRepository repository;

  WatchForumsUseCase(this.repository);

  Stream<Either<Failure, List<Forum>>> call(String communityId) {
    return repository.watchForums(communityId);
  }
}