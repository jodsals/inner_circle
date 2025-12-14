import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/post_repository.dart';

/// Use case for deleting a post
class DeletePost {
  final PostRepository repository;

  DeletePost(this.repository);

  Future<Either<Failure, void>> call(
      String communityId, String forumId, String postId) {
    return repository.deletePost(communityId, forumId, postId);
  }
}
