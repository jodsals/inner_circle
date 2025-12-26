import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';

/// Repository interface for comments
abstract class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(
      String communityId, String forumId, String postId);
  Future<Either<Failure, Comment>> getComment(
      String communityId, String forumId, String postId, String commentId);
  Future<Either<Failure, Comment>> createComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? parentId,
  });
  Future<Either<Failure, Comment>> updateComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  });
  Future<Either<Failure, void>> deleteComment(
      String communityId, String forumId, String postId, String commentId);
  Stream<Either<Failure, List<Comment>>> watchComments(
      String communityId, String forumId, String postId);
}
