import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../membership/domain/repositories/membership_repository.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// Implementation des Search Repository
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final MembershipRepository _membershipRepository;

  SearchRepositoryImpl(
    this._remoteDataSource,
    this._membershipRepository,
  );

  @override
  Future<Either<Failure, List<SearchResult>>> search({
    required String query,
    required String userId,
  }) async {
    try {
      // 1. Hole alle Communities, denen der User beigetreten ist
      final communitiesStream = _membershipRepository.getUserCommunities(userId);

      // Warte auf das erste Ergebnis vom Stream
      final communitiesResult = await communitiesStream.first;

      return communitiesResult.fold(
        (failure) => Left(failure),
        (communityIds) async {
          if (communityIds.isEmpty) {
            return const Right([]);
          }

          // 2. Suche in diesen Communities
          final results = await _remoteDataSource.search(
            query: query,
            communityIds: communityIds,
          );

          // 3. Konvertiere zu Entities
          final entities = results.map((model) => model.toEntity()).toList();

          return Right(entities);
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Suche fehlgeschlagen: ${e.toString()}'));
    }
  }
}
