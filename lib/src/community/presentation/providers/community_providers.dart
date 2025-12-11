import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
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