import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/membership_remote_datasource.dart';
import '../../data/repositories/membership_repository_impl.dart';
import '../../domain/usecases/check_membership.dart';
import '../../domain/usecases/get_user_communities.dart';
import '../../domain/usecases/join_community.dart';
import '../../domain/usecases/leave_community.dart';
import 'membership_controller.dart';

// ============================================
// DATA SOURCES
// ============================================

final membershipRemoteDataSourceProvider =
    Provider<MembershipRemoteDataSource>((ref) {
  return FirebaseMembershipRemoteDataSource(FirebaseFirestore.instance);
});

// ============================================
// REPOSITORIES
// ============================================

final membershipRepositoryProvider = Provider((ref) {
  return MembershipRepositoryImpl(
    ref.watch(membershipRemoteDataSourceProvider),
  );
});

// ============================================
// USE CASES
// ============================================

final joinCommunityUseCaseProvider = Provider((ref) {
  return JoinCommunity(ref.watch(membershipRepositoryProvider));
});

final leaveCommunityUseCaseProvider = Provider((ref) {
  return LeaveCommunity(ref.watch(membershipRepositoryProvider));
});

final checkMembershipUseCaseProvider = Provider((ref) {
  return CheckMembership(ref.watch(membershipRepositoryProvider));
});

final getUserCommunitiesUseCaseProvider = Provider((ref) {
  return GetUserCommunities(ref.watch(membershipRepositoryProvider));
});

// ============================================
// CONTROLLERS
// ============================================

final membershipControllerProvider =
    StateNotifierProvider<MembershipController, AsyncValue<void>>((ref) {
  return MembershipController(
    joinCommunity: ref.watch(joinCommunityUseCaseProvider),
    leaveCommunity: ref.watch(leaveCommunityUseCaseProvider),
    checkMembership: ref.watch(checkMembershipUseCaseProvider),
  );
});

// ============================================
// STREAM PROVIDERS
// ============================================

/// Stream of community IDs user is member of
final userCommunitiesStreamProvider =
    StreamProvider.family<List<String>, String>((ref, userId) {
  final useCase = ref.watch(getUserCommunitiesUseCaseProvider);
  return useCase(userId).map(
    (either) => either.fold(
      (failure) => <String>[],
      (communities) => communities,
    ),
  );
});

/// Check if user is member of a community
final isMemberProvider =
    FutureProvider.family<bool, MembershipParams>((ref, params) async {
  final useCase = ref.watch(checkMembershipUseCaseProvider);
  final result = await useCase(
    userId: params.userId,
    communityId: params.communityId,
  );
  return result.fold(
    (failure) => false,
    (isMember) => isMember,
  );
});

/// Parameter class for membership checks
class MembershipParams {
  final String userId;
  final String communityId;

  const MembershipParams(this.userId, this.communityId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          communityId == other.communityId;

  @override
  int get hashCode => userId.hashCode ^ communityId.hashCode;
}
