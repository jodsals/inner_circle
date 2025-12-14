import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for getting a single post
class GetPost {
  final PostRepository repository;

  GetPost(this.repository);

  Future<Either<Failure, Post>> call(
      String communityId, String forumId, String postId) {
    return repository.getPost(communityId, forumId, postId);
  }
}
