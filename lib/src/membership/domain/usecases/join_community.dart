import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/membership.dart';
import '../repositories/membership_repository.dart';

/// Use case for joining a community
class JoinCommunity {
  final MembershipRepository repository;

  JoinCommunity(this.repository);

  Future<Either<Failure, Membership>> call({
    required String userId,
    required String communityId,
  }) {
    return repository.joinCommunity(
      userId: userId,
      communityId: communityId,
    );
  }
}
