import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/forum.dart';

/// Abstract repository for forum operations
abstract class ForumRepository {
  /// Get all forums for a community
  Future<Either<Failure, List<Forum>>> getForums(String communityId);

  /// Get a single forum by ID
  Future<Either<Failure, Forum>> getForum(String communityId, String forumId);

  /// Create a new forum
  Future<Either<Failure, Forum>> createForum({
    required String communityId,
    required String title,
  });

  /// Update an existing forum
  Future<Either<Failure, Forum>> updateForum({
    required String communityId,
    required String forumId,
    required String title,
  });

  /// Delete a forum
  Future<Either<Failure, void>> deleteForum(String communityId, String forumId);

  /// Watch forums stream for a community
  Stream<Either<Failure, List<Forum>>> watchForums(String communityId);
}