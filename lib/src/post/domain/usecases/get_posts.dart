import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for getting all posts in a forum
class GetPosts {
  final PostRepository repository;

  GetPosts(this.repository);

  Future<Either<Failure, List<Post>>> call(
      String communityId, String forumId) {
    return repository.getPosts(communityId, forumId);
  }
}
