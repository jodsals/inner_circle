import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/membership_repository.dart';

/// Use case for checking if user is member of a community
class CheckMembership {
  final MembershipRepository repository;

  CheckMembership(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String communityId,
  }) {
    return repository.isMember(
      userId: userId,
      communityId: communityId,
    );
  }
}
