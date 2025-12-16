import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/forum_remote_datasource.dart';
import '../../data/repositories/forum_repository_impl.dart';
import '../../domain/repositories/forum_repository.dart';
import '../../domain/usecases/create_forum.dart';
import '../../domain/usecases/delete_forum.dart';
import '../../domain/usecases/get_forums.dart';
import '../../domain/usecases/update_forum.dart';
import '../../domain/usecases/watch_forums.dart';
import '../state/forum_state.dart';
import 'forum_controller.dart';

// ============================================================================
// Data Sources
// ============================================================================

final forumRemoteDataSourceProvider = Provider<ForumRemoteDataSource>((ref) {
  return FirebaseForumRemoteDataSource(
    ref.watch(firestoreProvider),
  );
});

// ============================================================================
// Repositories
// ============================================================================

final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return ForumRepositoryImpl(
    ref.watch(forumRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ============================================================================
// Use Cases
// ============================================================================

final createForumUseCaseProvider = Provider<CreateForumUseCase>((ref) {
  return CreateForumUseCase(ref.watch(forumRepositoryProvider));
});

final getForumsUseCaseProvider = Provider<GetForumsUseCase>((ref) {
  return GetForumsUseCase(ref.watch(forumRepositoryProvider));
});

final updateForumUseCaseProvider = Provider<UpdateForumUseCase>((ref) {
  return UpdateForumUseCase(ref.watch(forumRepositoryProvider));
});

final deleteForumUseCaseProvider = Provider<DeleteForumUseCase>((ref) {
  return DeleteForumUseCase(ref.watch(forumRepositoryProvider));
});

final watchForumsUseCaseProvider = Provider<WatchForumsUseCase>((ref) {
  return WatchForumsUseCase(ref.watch(forumRepositoryProvider));
});

// ============================================================================
// Controllers
// ============================================================================

final forumControllerProvider =
    StateNotifierProvider<ForumController, ForumState>((ref) {
  return ForumController(
    createForumUseCase: ref.watch(createForumUseCaseProvider),
    getForumsUseCase: ref.watch(getForumsUseCaseProvider),
    updateForumUseCase: ref.watch(updateForumUseCaseProvider),
    deleteForumUseCase: ref.watch(deleteForumUseCaseProvider),
    watchForumsUseCase: ref.watch(watchForumsUseCaseProvider),
  );
});

// ============================================================================
// Stream Providers
// ============================================================================

/// Forums stream provider for a specific community
final forumsStreamProvider = StreamProvider.family((ref, String communityId) {
  final useCase = ref.watch(watchForumsUseCaseProvider);
  return useCase(communityId);
});

/// Watch forums provider (returns Future for easier use in home_providers)
final watchForumsProvider = FutureProvider.family((ref, String communityId) async {
  final streamResult = await ref.watch(forumsStreamProvider(communityId).future);
  return streamResult;
});