import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/membership_repository.dart';

/// Use case for leaving a community
class LeaveCommunity {
  final MembershipRepository repository;

  LeaveCommunity(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String communityId,
  }) {
    return repository.leaveCommunity(
      userId: userId,
      communityId: communityId,
    );
  }
}
