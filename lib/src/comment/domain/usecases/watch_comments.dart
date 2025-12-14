import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for watching comments in real-time
class WatchComments {
  final CommentRepository repository;

  WatchComments(this.repository);

  Stream<Either<Failure, List<Comment>>> call(
      String communityId, String forumId, String postId) {
    return repository.watchComments(communityId, forumId, postId);
  }
}
