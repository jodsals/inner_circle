import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case for creating a new post
class CreatePost {
  final PostRepository repository;

  CreatePost(this.repository);

  Future<Either<Failure, Post>> call({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  }) {
    return repository.createPost(
      communityId: communityId,
      forumId: forumId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      title: title,
      content: content,
    );
  }
}
