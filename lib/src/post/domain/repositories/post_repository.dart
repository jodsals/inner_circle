import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

/// Repository interface for posts
abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts(
      String communityId, String forumId);
  Future<Either<Failure, Post>> getPost(
      String communityId, String forumId, String postId);
  Future<Either<Failure, Post>> createPost({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  });
  Future<Either<Failure, Post>> updatePost({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  });
  Future<Either<Failure, void>> deletePost(
      String communityId, String forumId, String postId);
  Stream<Either<Failure, List<Post>>> watchPosts(
      String communityId, String forumId);
  Future<Either<Failure, void>> incrementCommentCount(
      String communityId, String forumId, String postId);
  Future<Either<Failure, void>> decrementCommentCount(
      String communityId, String forumId, String postId);
}
