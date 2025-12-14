import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/comment_repository.dart';

/// Use case for deleting a comment
class DeleteComment {
  final CommentRepository repository;

  DeleteComment(this.repository);

  Future<Either<Failure, void>> call(
      String communityId, String forumId, String postId, String commentId) {
    return repository.deleteComment(communityId, forumId, postId, commentId);
  }
}
