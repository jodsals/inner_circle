import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/delete_post.dart';
import '../../domain/usecases/get_post.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/update_post.dart';
import '../../domain/usecases/watch_posts.dart';
import 'post_controller.dart';

// ============================================
// DATA SOURCES
// ============================================

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return FirebasePostRemoteDataSource(
    FirebaseFirestore.instance,
    encryptionService,
  );
});

// ============================================
// REPOSITORIES
// ============================================

final postRepositoryProvider = Provider((ref) {
  return PostRepositoryImpl(ref.watch(postRemoteDataSourceProvider));
});

// ============================================
// USE CASES
// ============================================

final createPostUseCaseProvider = Provider((ref) {
  return CreatePost(ref.watch(postRepositoryProvider));
});

final getPostsUseCaseProvider = Provider((ref) {
  return GetPosts(ref.watch(postRepositoryProvider));
});

final getPostUseCaseProvider = Provider((ref) {
  return GetPost(ref.watch(postRepositoryProvider));
});

final updatePostUseCaseProvider = Provider((ref) {
  return UpdatePost(ref.watch(postRepositoryProvider));
});

final deletePostUseCaseProvider = Provider((ref) {
  return DeletePost(ref.watch(postRepositoryProvider));
});

final watchPostsUseCaseProvider = Provider((ref) {
  return WatchPosts(ref.watch(postRepositoryProvider));
});

// ============================================
// CONTROLLERS
// ============================================

final postControllerProvider =
    StateNotifierProvider<PostController, AsyncValue<void>>((ref) {
  return PostController(
    createPost: ref.watch(createPostUseCaseProvider),
    getPosts: ref.watch(getPostsUseCaseProvider),
    getPost: ref.watch(getPostUseCaseProvider),
    updatePost: ref.watch(updatePostUseCaseProvider),
    deletePost: ref.watch(deletePostUseCaseProvider),
  );
});

// ============================================
// STREAM PROVIDERS FOR REAL-TIME UPDATES
// ============================================

/// Parameter class for watchPostsProvider
class ForumParams {
  final String communityId;
  final String forumId;

  const ForumParams(this.communityId, this.forumId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForumParams &&
          runtimeType == other.runtimeType &&
          communityId == other.communityId &&
          forumId == other.forumId;

  @override
  int get hashCode => communityId.hashCode ^ forumId.hashCode;
}

/// Watch posts for a specific forum
final watchPostsProvider = StreamProvider.family<List<dynamic>, ForumParams>((ref, params) {
  print('Creating stream for community: ${params.communityId}, forum: ${params.forumId}');

  final watchPosts = ref.watch(watchPostsUseCaseProvider);

  return watchPosts(params.communityId, params.forumId).handleError((error) {
    // Log error for debugging
    print('Error watching posts: $error');
    return const [];
  }).map(
    (either) => either.fold(
      (failure) {
        print('Failure loading posts: ${failure.message}');
        return <dynamic>[];
      },
      (posts) {
        print('Successfully loaded ${posts.length} posts');
        return posts;
      },
    ),
  );
});
