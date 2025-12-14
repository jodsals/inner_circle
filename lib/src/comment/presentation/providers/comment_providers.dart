import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/usecases/create_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/update_comment.dart';
import '../../domain/usecases/watch_comments.dart';
import 'comment_controller.dart';

// ============================================
// DATA SOURCES
// ============================================

final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  return FirebaseCommentRemoteDataSource(FirebaseFirestore.instance);
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

/// Watch comments for a specific post
final watchCommentsProvider = StreamProvider.family<List<dynamic>, Map<String, String>>((ref, params) {
  final watchComments = ref.watch(watchCommentsUseCaseProvider);
  final communityId = params['communityId']!;
  final forumId = params['forumId']!;
  final postId = params['postId']!;

  return watchComments(communityId, forumId, postId).map(
    (either) => either.fold(
      (failure) => throw Exception(failure.message),
      (comments) => comments,
    ),
  );
});
