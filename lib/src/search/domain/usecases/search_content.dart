import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

/// Use Case für die Suche in Posts und Comments
class SearchContentUseCase {
  final SearchRepository _repository;

  SearchContentUseCase(this._repository);

  Future<Either<Failure, List<SearchResult>>> execute({
    required String query,
    required String userId,
  }) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    return await _repository.search(
      query: query.trim(),
      userId: userId,
    );
  }
}
