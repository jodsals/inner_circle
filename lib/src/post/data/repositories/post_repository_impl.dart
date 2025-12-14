import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

/// Implementation of PostRepository
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Post>>> getPosts(
      String communityId, String forumId) async {
    try {
      final posts = await remoteDataSource.getPosts(communityId, forumId);
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(
      String communityId, String forumId, String postId) async {
    try {
      final post = await remoteDataSource.getPost(communityId, forumId, postId);
      return Right(post);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        communityId: communityId,
        forumId: forumId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title,
        content: content,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Post>> updatePost({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  }) async {
    try {
      final post = await remoteDataSource.updatePost(
        communityId: communityId,
        forumId: forumId,
        postId: postId,
        title: title,
        content: content,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(
      String communityId, String forumId, String postId) async {
    try {
      await remoteDataSource.deletePost(communityId, forumId, postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Post>>> watchPosts(
      String communityId, String forumId) {
    try {
      return remoteDataSource
          .watchPosts(communityId, forumId)
          .map((posts) => Right<Failure, List<Post>>(posts))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<Post>>(ServerFailure(error.message));
        }
        return Left<Failure, List<Post>>(
            ServerFailure('Unexpected error: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Unexpected error: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> incrementCommentCount(
      String communityId, String forumId, String postId) async {
    try {
      await remoteDataSource.incrementCommentCount(
          communityId, forumId, postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> decrementCommentCount(
      String communityId, String forumId, String postId) async {
    try {
      await remoteDataSource.decrementCommentCount(
          communityId, forumId, postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
