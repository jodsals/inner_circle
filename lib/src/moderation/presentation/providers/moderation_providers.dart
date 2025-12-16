import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/models/review_request_model.dart';
import '../../data/services/ai_moderation_service.dart';

// ============================================================================
// Services
// ============================================================================

final aiModerationServiceProvider = Provider<AIModerationService>((ref) {
  return AIModerationService();
});

// ============================================================================
// Data Sources
// ============================================================================

final reviewRemoteDataSourceProvider =
    Provider<ReviewRemoteDataSource>((ref) {
  return FirebaseReviewRemoteDataSource(
    ref.watch(firestoreProvider),
  );
});

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for analyzing content
final analyzeContentProvider = Provider((ref) {
  final service = ref.watch(aiModerationServiceProvider);
  return ({required String content}) async {
    return await service.analyzeContent(content);
  };
});

/// Provider for creating review requests
final createReviewRequestProvider = Provider((ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ({
    required String userId,
    required String content,
    required String contentType,
    String? communityId,
    String? forumId,
    required List<String> flagReasons,
    required double confidenceScore,
  }) async {
    final request = await dataSource.createReviewRequest(
      ReviewRequestModel(
        id: '', // Will be set by Firestore
        userId: userId,
        content: content,
        contentType: contentType,
        communityId: communityId,
        forumId: forumId,
        flagReasons: flagReasons,
        confidenceScore: confidenceScore,
        requestedAt: DateTime.now(),
      ),
    );
    return request;
  };
});