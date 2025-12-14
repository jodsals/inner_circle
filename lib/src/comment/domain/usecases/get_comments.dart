import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for getting all comments for a post
class GetComments {
  final CommentRepository repository;

  GetComments(this.repository);

  Future<Either<Failure, List<Comment>>> call(
      String communityId, String forumId, String postId) {
    return repository.getComments(communityId, forumId, postId);
  }
}
