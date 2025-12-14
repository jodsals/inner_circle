import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../post/data/datasources/post_remote_datasource.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/create_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/update_comment.dart';

/// Controller for managing comment operations
class CommentController extends StateNotifier<AsyncValue<void>> {
  final CreateComment createComment;
  final GetComments getComments;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;

  CommentController({
    required this.createComment,
    required this.getComments,
    required this.updateComment,
    required this.deleteComment,
  }) : super(const AsyncValue.data(null));

  /// Create a new comment
  Future<Comment?> createNewComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    required PostRemoteDataSource postDataSource,
  }) async {
    state = const AsyncValue.loading();

    final result = await createComment(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (comment) async {
        // Increment comment count in post
        try {
          await postDataSource.incrementCommentCount(
              communityId, forumId, postId);
        } catch (e) {
          // Ignore error, comment was created successfully
        }
        state = const AsyncValue.data(null);
        return comment;
      },
    );
  }

  /// Get all comments for a post
  Future<List<Comment>> getCommentsForPost(
      String communityId, String forumId, String postId) async {
    state = const AsyncValue.loading();

    final result = await getComments(communityId, forumId, postId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return [];
      },
      (comments) {
        state = const AsyncValue.data(null);
        return comments;
      },
    );
  }

  /// Update a comment
  Future<Comment?> updateExistingComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  }) async {
    state = const AsyncValue.loading();

    final result = await updateComment(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      commentId: commentId,
      content: content,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (comment) {
        state = const AsyncValue.data(null);
        return comment;
      },
    );
  }

  /// Delete a comment
  Future<bool> deleteExistingComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required PostRemoteDataSource postDataSource,
  }) async {
    state = const AsyncValue.loading();

    final result =
        await deleteComment(communityId, forumId, postId, commentId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) async {
        // Decrement comment count in post
        try {
          await postDataSource.decrementCommentCount(
              communityId, forumId, postId);
        } catch (e) {
          // Ignore error, comment was deleted successfully
        }
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}
