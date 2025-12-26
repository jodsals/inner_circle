import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/usecases/create_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/update_comment.dart';
import '../../domain/usecases/watch_comments.dart';
import 'comment_controller.dart';

export 'comment_controller.dart' show CommentController;
export 'comment_providers.dart' show CommentParams;

// ============================================
// DATA SOURCES
// ============================================

final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return FirebaseCommentRemoteDataSource(
    FirebaseFirestore.instance,
    encryptionService,
  );
});

// ============================================
// REPOSITORIES
// ============================================

final commentRepositoryProvider = Provider((ref) {
  return CommentRepositoryImpl(ref.watch(commentRemoteDataSourceProvider));
});

// ============================================
// USE CASES
// ============================================

final createCommentUseCaseProvider = Provider((ref) {
  return CreateComment(ref.watch(commentRepositoryProvider));
});

final getCommentsUseCaseProvider = Provider((ref) {
  return GetComments(ref.watch(commentRepositoryProvider));
});

final updateCommentUseCaseProvider = Provider((ref) {
  return UpdateComment(ref.watch(commentRepositoryProvider));
});

final deleteCommentUseCaseProvider = Provider((ref) {
  return DeleteComment(ref.watch(commentRepositoryProvider));
});

final watchCommentsUseCaseProvider = Provider((ref) {
  return WatchComments(ref.watch(commentRepositoryProvider));
});

// ============================================
// CONTROLLERS
// ============================================

final commentControllerProvider =
    StateNotifierProvider<CommentController, AsyncValue<void>>((ref) {
  return CommentController(
    createComment: ref.watch(createCommentUseCaseProvider),
    getComments: ref.watch(getCommentsUseCaseProvider),
    updateComment: ref.watch(updateCommentUseCaseProvider),
    deleteComment: ref.watch(deleteCommentUseCaseProvider),
  );
});

// ============================================
// STREAM PROVIDERS FOR REAL-TIME UPDATES
// ============================================

/// Parameter class for watchCommentsProvider
class CommentParams {
  final String communityId;
  final String forumId;
  final String postId;

  const CommentParams(this.communityId, this.forumId, this.postId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentParams &&
          runtimeType == other.runtimeType &&
          communityId == other.communityId &&
          forumId == other.forumId &&
          postId == other.postId;

  @override
  int get hashCode =>
      communityId.hashCode ^ forumId.hashCode ^ postId.hashCode;
}

/// Watch comments for a specific post
final watchCommentsProvider = StreamProvider.family<List<dynamic>, CommentParams>((ref, params) {
  print('Creating comment stream for community: ${params.communityId}, forum: ${params.forumId}, post: ${params.postId}');

  final watchComments = ref.watch(watchCommentsUseCaseProvider);

  return watchComments(params.communityId, params.forumId, params.postId).handleError((error) {
    print('Error watching comments: $error');
    return const [];
  }).map(
    (either) => either.fold(
      (failure) {
        print('Failure loading comments: ${failure.message}');
        return <dynamic>[];
      },
      (comments) {
        print('Successfully loaded ${comments.length} comments');
        return comments;
      },
    ),
  );
});
