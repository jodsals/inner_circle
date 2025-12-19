import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/research_paper_model.dart';
import '../../data/services/core_api_service.dart';

/// Provider for CORE API service
final coreApiServiceProvider = Provider<CoreApiService>((ref) {
  return CoreApiService();
});

/// Provider for health news (default papers)
final healthNewsProvider = FutureProvider<List<ResearchPaperModel>>((ref) async {
  final service = ref.watch(coreApiServiceProvider);
  return await service.getHealthNews();
});

/// Search parameters class
class SearchParams {
  final String query;
  final String? language;
  final int? yearFrom;
  final int? yearTo;

  const SearchParams({
    required this.query,
    this.language,
    this.yearFrom,
    this.yearTo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          query == other.query &&
          language == other.language &&
          yearFrom == other.yearFrom &&
          yearTo == other.yearTo;

  @override
  int get hashCode =>
      query.hashCode ^
      (language?.hashCode ?? 0) ^
      (yearFrom?.hashCode ?? 0) ^
      (yearTo?.hashCode ?? 0);
}

/// Provider for searching papers with filters
final searchPapersProvider = FutureProvider.family<List<ResearchPaperModel>, SearchParams>(
  (ref, params) async {
    if (params.query.isEmpty) {
      return [];
    }
    final service = ref.watch(coreApiServiceProvider);
    return await service.searchPapers(
      params.query,
      language: params.language,
      yearFrom: params.yearFrom,
      yearTo: params.yearTo,
    );
  },
);

/// Provider for rate limit info
final rateLimitInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(coreApiServiceProvider);
  return service.getRateLimitInfo();
});

/// Provider for downloading PDF
final downloadPdfProvider = Provider<Future<String?> Function(String paperId, String paperTitle)>((ref) {
  final service = ref.watch(coreApiServiceProvider);
  return (String paperId, String paperTitle) => service.downloadPdf(paperId, paperTitle);
});
