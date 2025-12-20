import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_result.dart';

/// Repository für Such-Funktionalität
abstract class SearchRepository {
  /// Suche in Posts und Comments in den Communities des Users
  /// [query] - Suchbegriff
  /// [userId] - User ID, um nur in seinen Communities zu suchen
  Future<Either<Failure, List<SearchResult>>> search({
    required String query,
    required String userId,
  });
}
