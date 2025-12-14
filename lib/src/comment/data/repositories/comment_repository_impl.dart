import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

/// Implementation of CommentRepository
class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Comment>>> getComments(
      String communityId, String forumId, String postId) async {
    try {
      final comments =
          await remoteDataSource.getComments(communityId, forumId, postId);
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Comment>> getComment(String communityId,
      String forumId, String postId, String commentId) async {
    try {
      final comment = await remoteDataSource.getComment(
          communityId, forumId, postId, commentId);
      return Right(comment);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Comment>> createComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    try {
      final comment = await remoteDataSource.createComment(
        communityId: communityId,
        forumId: forumId,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      final comment = await remoteDataSource.updateComment(
        communityId: communityId,
        forumId: forumId,
        postId: postId,
        commentId: commentId,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String communityId,
      String forumId, String postId, String commentId) async {
    try {
      await remoteDataSource.deleteComment(
          communityId, forumId, postId, commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Comment>>> watchComments(
      String communityId, String forumId, String postId) {
    try {
      return remoteDataSource
          .watchComments(communityId, forumId, postId)
          .map((comments) => Right<Failure, List<Comment>>(comments))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<Comment>>(ServerFailure(error.message));
        }
        return Left<Failure, List<Comment>>(
            ServerFailure('Unexpected error: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Unexpected error: $e')));
    }
  }
}
