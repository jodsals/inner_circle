import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for updating a post
class UpdatePost {
  final PostRepository repository;

  UpdatePost(this.repository);

  Future<Either<Failure, Post>> call({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  }) {
    return repository.updatePost(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      title: title,
      content: content,
    );
  }
}
