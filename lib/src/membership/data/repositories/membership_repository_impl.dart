import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/membership.dart';
import '../../domain/repositories/membership_repository.dart';
import '../datasources/membership_remote_datasource.dart';

/// Implementation of MembershipRepository
class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDataSource remoteDataSource;

  MembershipRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Membership>> joinCommunity({
    required String userId,
    required String communityId,
  }) async {
    try {
      final membership = await remoteDataSource.joinCommunity(
        userId: userId,
        communityId: communityId,
      );
      return Right(membership);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveCommunity({
    required String userId,
    required String communityId,
  }) async {
    try {
      await remoteDataSource.leaveCommunity(
        userId: userId,
        communityId: communityId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isMember({
    required String userId,
    required String communityId,
  }) async {
    try {
      final isMember = await remoteDataSource.isMember(
        userId: userId,
        communityId: communityId,
      );
      return Right(isMember);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<String>>> getUserCommunities(String userId) {
    try {
      return remoteDataSource.getUserCommunities(userId).map(
        (communities) => Right<Failure, List<String>>(communities),
      ).handleError(
        (error) => Left<Failure, List<String>>(ServerFailure(error.toString())),
      );
    } catch (e) {
      return Stream.value(Left<Failure, List<String>>(ServerFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<String>>> getCommunityMembers(
      String communityId) {
    try {
      return remoteDataSource.getCommunityMembers(communityId).map(
        (members) => Right<Failure, List<String>>(members),
      ).handleError(
        (error) => Left<Failure, List<String>>(ServerFailure(error.toString())),
      );
    } catch (e) {
      return Stream.value(Left<Failure, List<String>>(ServerFailure(e.toString())));
    }
  }
}
