import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for creating a new comment
class CreateComment {
  final CommentRepository repository;

  CreateComment(this.repository);

  Future<Either<Failure, Comment>> call({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? parentId,
  }) {
    return repository.createComment(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content,
      parentId: parentId,
    );
  }
}
