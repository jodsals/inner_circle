import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/delete_post.dart';
import '../../domain/usecases/get_post.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/update_post.dart';

/// Controller for managing post operations
class PostController extends StateNotifier<AsyncValue<void>> {
  final CreatePost createPost;
  final GetPosts getPosts;
  final GetPost getPost;
  final UpdatePost updatePost;
  final DeletePost deletePost;

  PostController({
    required this.createPost,
    required this.getPosts,
    required this.getPost,
    required this.updatePost,
    required this.deletePost,
  }) : super(const AsyncValue.data(null));

  /// Create a new post
  Future<Post?> createNewPost({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  }) async {
    state = const AsyncValue.loading();

    final result = await createPost(
      communityId: communityId,
      forumId: forumId,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      title: title,
      content: content,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (post) {
        state = const AsyncValue.data(null);
        return post;
      },
    );
  }

  /// Get all posts for a forum
  Future<List<Post>> getPostsForForum(
      String communityId, String forumId) async {
    state = const AsyncValue.loading();

    final result = await getPosts(communityId, forumId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return [];
      },
      (posts) {
        state = const AsyncValue.data(null);
        return posts;
      },
    );
  }

  /// Get a single post
  Future<Post?> getSinglePost(
      String communityId, String forumId, String postId) async {
    state = const AsyncValue.loading();

    final result = await getPost(communityId, forumId, postId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (post) {
        state = const AsyncValue.data(null);
        return post;
      },
    );
  }

  /// Update a post
  Future<Post?> updateExistingPost({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  }) async {
    state = const AsyncValue.loading();

    final result = await updatePost(
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      title: title,
      content: content,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (post) {
        state = const AsyncValue.data(null);
        return post;
      },
    );
  }

  /// Delete a post
  Future<bool> deleteExistingPost(
      String communityId, String forumId, String postId) async {
    state = const AsyncValue.loading();

    final result = await deletePost(communityId, forumId, postId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}
