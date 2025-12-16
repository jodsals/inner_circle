import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/usecases/create_community.dart';
import '../../domain/usecases/delete_community.dart';
import '../../domain/usecases/get_communities.dart';
import '../../domain/usecases/update_community.dart';
import '../../domain/usecases/watch_communities.dart';
import '../state/community_state.dart';
import 'community_controller.dart';

// ============================================================================
// Data Sources
// ============================================================================

final communityRemoteDataSourceProvider =
    Provider<CommunityRemoteDataSource>((ref) {
  return FirebaseCommunityRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

// ============================================================================
// Repositories
// ============================================================================

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(
    ref.watch(communityRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ============================================================================
// Use Cases
// ============================================================================

final createCommunityUseCaseProvider = Provider<CreateCommunityUseCase>((ref) {
  return CreateCommunityUseCase(ref.watch(communityRepositoryProvider));
});

final getCommunitiesUseCaseProvider = Provider<GetCommunitiesUseCase>((ref) {
  return GetCommunitiesUseCase(ref.watch(communityRepositoryProvider));
});

final updateCommunityUseCaseProvider = Provider<UpdateCommunityUseCase>((ref) {
  return UpdateCommunityUseCase(ref.watch(communityRepositoryProvider));
});

final deleteCommunityUseCaseProvider = Provider<DeleteCommunityUseCase>((ref) {
  return DeleteCommunityUseCase(ref.watch(communityRepositoryProvider));
});

final watchCommunitiesUseCaseProvider = Provider<WatchCommunitiesUseCase>((ref) {
  return WatchCommunitiesUseCase(ref.watch(communityRepositoryProvider));
});

// ============================================================================
// Controllers
// ============================================================================

final communityControllerProvider =
    StateNotifierProvider<CommunityController, CommunityState>((ref) {
  return CommunityController(
    createCommunityUseCase: ref.watch(createCommunityUseCaseProvider),
    getCommunitiesUseCase: ref.watch(getCommunitiesUseCaseProvider),
    updateCommunityUseCase: ref.watch(updateCommunityUseCaseProvider),
    deleteCommunityUseCase: ref.watch(deleteCommunityUseCaseProvider),
    watchCommunitiesUseCase: ref.watch(watchCommunitiesUseCaseProvider),
  );
});

// ============================================================================
// Stream Providers
// ============================================================================

final communitiesStreamProvider = StreamProvider((ref) {
  final useCase = ref.watch(watchCommunitiesUseCaseProvider);
  return useCase();
});

// ============================================================================
// Like Providers
// ============================================================================

/// Check if user has liked a community
final isLikedProvider =
    FutureProvider.family<bool, LikeParams>((ref, params) async {
  final dataSource = ref.watch(communityRemoteDataSourceProvider);
  try {
    return await dataSource.isLiked(
      userId: params.userId,
      communityId: params.communityId,
    );
  } catch (e) {
    return false;
  }
});

/// Like/Unlike provider for toggling like status
final likeCommunityProvider = Provider((ref) {
  final dataSource = ref.watch(communityRemoteDataSourceProvider);

  return ({required String userId, required String communityId}) async {
    final isLiked = await dataSource.isLiked(
      userId: userId,
      communityId: communityId,
    );

    if (isLiked) {
      await dataSource.unlikeCommunity(
        userId: userId,
        communityId: communityId,
      );
    } else {
      await dataSource.likeCommunity(
        userId: userId,
        communityId: communityId,
      );
    }

    // Invalidate to refresh UI
    ref.invalidate(isLikedProvider(LikeParams(userId, communityId)));
    ref.invalidate(communitiesStreamProvider);
    ref.invalidate(favoritesCommunitiesProvider);
  };
});

/// Parameter class for like operations
class LikeParams {
  final String userId;
  final String communityId;

  const LikeParams(this.userId, this.communityId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          communityId == other.communityId;

  @override
  int get hashCode => userId.hashCode ^ communityId.hashCode;
}

/// Provider for user's favorite (liked) communities
final favoritesCommunitiesProvider = FutureProvider<List<dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final communitiesAsync = await ref.watch(communitiesStreamProvider.future);

  return communitiesAsync.fold(
    (failure) => [],
    (communities) async {
      final favorites = <dynamic>[];
      for (final community in communities) {
        try {
          final isLiked = await ref.read(communityRemoteDataSourceProvider).isLiked(
            userId: user.id,
            communityId: community.id,
          );
          if (isLiked) favorites.add(community);
        } catch (e) {
          // Skip on error
        }
      }
      return favorites;
    },
  );
});