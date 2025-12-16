import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/membership_repository.dart';

/// Use case for getting all communities user is member of
class GetUserCommunities {
  final MembershipRepository repository;

  GetUserCommunities(this.repository);

  Stream<Either<Failure, List<String>>> call(String userId) {
    return repository.getUserCommunities(userId);
  }
}
