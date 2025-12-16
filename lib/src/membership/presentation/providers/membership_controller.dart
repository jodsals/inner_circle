import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/check_membership.dart';
import '../../domain/usecases/join_community.dart';
import '../../domain/usecases/leave_community.dart';

/// Controller for membership operations
class MembershipController extends StateNotifier<AsyncValue<void>> {
  final JoinCommunity joinCommunity;
  final LeaveCommunity leaveCommunity;
  final CheckMembership checkMembership;

  MembershipController({
    required this.joinCommunity,
    required this.leaveCommunity,
    required this.checkMembership,
  }) : super(const AsyncValue.data(null));

  /// Join a community
  Future<bool> join({
    required String userId,
    required String communityId,
  }) async {
    state = const AsyncValue.loading();

    final result = await joinCommunity(
      userId: userId,
      communityId: communityId,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (membership) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  /// Leave a community
  Future<bool> leave({
    required String userId,
    required String communityId,
  }) async {
    state = const AsyncValue.loading();

    final result = await leaveCommunity(
      userId: userId,
      communityId: communityId,
    );

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

  /// Check if user is member
  Future<bool> isMember({
    required String userId,
    required String communityId,
  }) async {
    final result = await checkMembership(
      userId: userId,
      communityId: communityId,
    );

    return result.fold(
      (failure) => false,
      (isMember) => isMember,
    );
  }
}
