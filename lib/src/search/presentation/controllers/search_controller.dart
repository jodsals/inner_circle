import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/search_content.dart';
import '../state/search_state.dart';

/// Controller für Suche
class SearchController extends StateNotifier<SearchState> {
  final SearchContentUseCase _searchContentUseCase;

  SearchController({
    required SearchContentUseCase searchContentUseCase,
  })  : _searchContentUseCase = searchContentUseCase,
        super(SearchState.initial());

  /// Suche durchführen
  Future<void> search(String query, String userId) async {
    if (query.trim().isEmpty) {
      state = SearchState.initial();
      return;
    }

    state = SearchState.loading(query);

    final result = await _searchContentUseCase.execute(
      query: query,
      userId: userId,
    );

    result.fold(
      (failure) {
        state = SearchState.error(failure.message, query);
      },
      (results) {
        state = SearchState.success(results, query);
      },
    );
  }

  /// Suche zurücksetzen
  void clearSearch() {
    state = SearchState.initial();
  }

  /// Fehler löschen
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
