import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_community.dart';
import '../../domain/usecases/delete_community.dart';
import '../../domain/usecases/get_communities.dart';
import '../../domain/usecases/update_community.dart';
import '../../domain/usecases/watch_communities.dart';
import '../state/community_state.dart';

/// Controller for community operations
class CommunityController extends StateNotifier<CommunityState> {
  final CreateCommunityUseCase createCommunityUseCase;
  final GetCommunitiesUseCase getCommunitiesUseCase;
  final UpdateCommunityUseCase updateCommunityUseCase;
  final DeleteCommunityUseCase deleteCommunityUseCase;
  final WatchCommunitiesUseCase watchCommunitiesUseCase;

  CommunityController({
    required this.createCommunityUseCase,
    required this.getCommunitiesUseCase,
    required this.updateCommunityUseCase,
    required this.deleteCommunityUseCase,
    required this.watchCommunitiesUseCase,
  }) : super(CommunityState.initial()) {
    loadCommunities();
  }

  /// Load all communities
  Future<void> loadCommunities() async {
    state = state.copyWithLoading();

    final result = await getCommunitiesUseCase();

    result.fold(
      (failure) => state = state.copyWithError(failure.message),
      (communities) => state = state.copyWithSuccess(communities: communities),
    );
  }

  /// Create a new community
  Future<bool> createCommunity({
    required String title,
    required String description,
    String? bannerImagePath,
  }) async {
    state = state.copyWithLoading();

    final result = await createCommunityUseCase(
      title: title,
      description: description,
      bannerImagePath: bannerImagePath,
    );

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (community) {
        // Reload communities to include the new one
        loadCommunities();
        return true;
      },
    );
  }

  /// Update an existing community
  Future<bool> updateCommunity({
    required String id,
    String? title,
    String? description,
    String? bannerImagePath,
  }) async {
    state = state.copyWithLoading();

    final result = await updateCommunityUseCase(
      id: id,
      title: title,
      description: description,
      bannerImagePath: bannerImagePath,
    );

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (community) {
        // Reload communities to reflect the update
        loadCommunities();
        return true;
      },
    );
  }

  /// Delete a community
  Future<bool> deleteCommunity(String id) async {
    state = state.copyWithLoading();

    final result = await deleteCommunityUseCase(id);

    return result.fold(
      (failure) {
        state = state.copyWithError(failure.message);
        return false;
      },
      (_) {
        // Reload communities to remove the deleted one
        loadCommunities();
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = CommunityState(
      communities: state.communities,
      selectedCommunity: state.selectedCommunity,
    );
  }
}