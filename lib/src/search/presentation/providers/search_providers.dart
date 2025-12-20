import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../membership/presentation/providers/membership_providers.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_content.dart';
import '../controllers/search_controller.dart';
import '../state/search_state.dart';

// ============================================================================
// Data Sources
// ============================================================================

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return FirebaseSearchRemoteDataSource(
    ref.watch(firestoreProvider),
  );
});

// ============================================================================
// Repositories
// ============================================================================

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(
    ref.watch(searchRemoteDataSourceProvider),
    ref.watch(membershipRepositoryProvider),
  );
});

// ============================================================================
// Use Cases
// ============================================================================

final searchContentUseCaseProvider = Provider<SearchContentUseCase>((ref) {
  return SearchContentUseCase(
    ref.watch(searchRepositoryProvider),
  );
});

// ============================================================================
// Controllers
// ============================================================================

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  return SearchController(
    searchContentUseCase: ref.watch(searchContentUseCaseProvider),
  );
});
