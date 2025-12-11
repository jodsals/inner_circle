import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_forum.dart';
import '../../domain/usecases/delete_forum.dart';
import '../../domain/usecases/get_forums.dart';
import '../../domain/usecases/update_forum.dart';
import '../../domain/usecases/watch_forums.dart';
import '../state/forum_state.dart';

/// Controller for forum operations
class ForumController extends StateNotifier<ForumState> {
  final CreateForumUseCase createForumUseCase;
  final GetForumsUseCase getForumsUseCase;
  final UpdateForumUseCase updateForumUseCase;
  final DeleteForumUseCase deleteForumUseCase;
  final WatchForumsUseCase watchForumsUseCase;

  ForumController({
    required this.createForumUseCase,
    required this.getForumsUseCase,
    required this.updateForumUseCase,
    required this.deleteForumUseCase,
    required this.watchForumsUseCase,
  }) : super(ForumState.initial());

  /// Load all forums for a community
  Future<void> loadForums(String communityId) async {
    state = state.copyWithLoading();

    final result = await getForumsUseCase(communityId);

    result.fold(
      (failure) => state = state.copyWithError(failure.message),
      (forums) => state = state.copyWithSuccess(
        forums: forums,
        selectedCommunityId: communityId,
      ),
    );
  }

  /// Create a new forum
  Future<bool> createForum({
    required String communityId,
    required String title,
  }) async {
    state = state.copyWithLoading();

    final result = await createForumUseCase(
      communityId: communityId,
      title: title,
    );

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (forum) {
        // Reload forums to include the new one
        loadForums(communityId);
        return true;
      },
    );
  }

  /// Update an existing forum
  Future<bool> updateForum({
    required String communityId,
    required String forumId,
    required String title,
  }) async {
    state = state.copyWithLoading();

    final result = await updateForumUseCase(
      communityId: communityId,
      forumId: forumId,
      title: title,
    );

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (forum) {
        // Reload forums to reflect the update
        loadForums(communityId);
        return true;
      },
    );
  }

  /// Delete a forum
  Future<bool> deleteForum(String communityId, String forumId) async {
    state = state.copyWithLoading();

    final result = await deleteForumUseCase(communityId, forumId);

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (_) {
        // Reload forums to remove the deleted one
        loadForums(communityId);
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = ForumState(
      forums: state.forums,
      selectedForum: state.selectedForum,
      selectedCommunityId: state.selectedCommunityId,
    );
  }
}