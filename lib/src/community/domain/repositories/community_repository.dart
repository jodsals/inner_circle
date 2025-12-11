import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community.dart';

/// Abstract repository for community operations
abstract class CommunityRepository {
  /// Get all communities
  Future<Either<Failure, List<Community>>> getCommunities();

  /// Get a single community by ID
  Future<Either<Failure, Community>> getCommunity(String id);

  /// Create a new community
  Future<Either<Failure, Community>> createCommunity({
    required String title,
    required String description,
    String? bannerImagePath,
  });

  /// Update an existing community
  Future<Either<Failure, Community>> updateCommunity({
    required String id,
    String? title,
    String? description,
    String? bannerImagePath,
  });

  /// Delete a community
  Future<Either<Failure, void>> deleteCommunity(String id);

  /// Watch communities stream
  Stream<Either<Failure, List<Community>>> watchCommunities();
}