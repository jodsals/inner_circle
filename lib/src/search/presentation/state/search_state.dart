import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

/// State für Suche
class SearchState extends Equatable {
  final List<SearchResult> results;
  final bool isLoading;
  final String? errorMessage;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
    this.query = '',
  });

  /// Initial state
  factory SearchState.initial() {
    return const SearchState();
  }

  /// Loading state
  factory SearchState.loading(String query) {
    return SearchState(
      isLoading: true,
      query: query,
    );
  }

  /// Success state
  factory SearchState.success(List<SearchResult> results, String query) {
    return SearchState(
      results: results,
      isLoading: false,
      query: query,
    );
  }

  /// Error state
  factory SearchState.error(String message, String query) {
    return SearchState(
      isLoading: false,
      errorMessage: message,
      query: query,
    );
  }

  /// Copy with
  SearchState copyWith({
    List<SearchResult>? results,
    bool? isLoading,
    String? errorMessage,
    String? query,
    bool clearError = false,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [results, isLoading, errorMessage, query];
}
