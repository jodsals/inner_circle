import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for watching posts in real-time
class WatchPosts {
  final PostRepository repository;

  WatchPosts(this.repository);

  Stream<Either<Failure, List<Post>>> call(String communityId, String forumId) {
    return repository.watchPosts(communityId, forumId);
  }
}
