import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for updating a comment
class UpdateComment {
  final CommentRepository repository;

  UpdateComment(this.repository);

  Future<Either<Failure, Comment>> call({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  }) {
    return repository.updateComment(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      commentId: commentId,
      content: content,
    );
  }
}
