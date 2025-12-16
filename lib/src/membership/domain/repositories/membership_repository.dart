import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/membership.dart';

/// Repository for membership operations
abstract class MembershipRepository {
  /// Join a community
  Future<Either<Failure, Membership>> joinCommunity({
    required String userId,
    required String communityId,
  });

  /// Leave a community
  Future<Either<Failure, void>> leaveCommunity({
    required String userId,
    required String communityId,
  });

  /// Check if user is member of a community
  Future<Either<Failure, bool>> isMember({
    required String userId,
    required String communityId,
  });

  /// Get all communities user is member of
  Stream<Either<Failure, List<String>>> getUserCommunities(String userId);

  /// Get all members of a community
  Stream<Either<Failure, List<String>>> getCommunityMembers(String communityId);
}
