import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../comment/presentation/providers/comment_providers.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/models/review_request_model.dart';
import '../../data/services/ai_moderation_service.dart';

// ============================================================================
// Services
// ============================================================================

final aiModerationServiceProvider = Provider<AIModerationService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AIModerationService(secureStorage: secureStorage);
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
    String? contentId,
    String? postId,
    String? communityId,
    String? forumId,
    String? title,
    String? authorName,
    String? authorPhotoUrl,
    required List<String> flagReasons,
    required double confidenceScore,
  }) async {
    final request = await dataSource.createReviewRequest(
      ReviewRequestModel(
        id: '', // Will be set by Firestore
        userId: userId,
        content: content,
        contentType: contentType,
        contentId: contentId,
        postId: postId,
        communityId: communityId,
        forumId: forumId,
        title: title,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        flagReasons: flagReasons,
        confidenceScore: confidenceScore,
        requestedAt: DateTime.now(),
      ),
    );
    return request;
  };
});

/// Provider for getting pending reviews
final getPendingReviewsProvider = FutureProvider((ref) async {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  return await dataSource.getPendingReviews();
});

/// Provider for watching pending reviews (real-time updates)
final watchPendingReviewsProvider = StreamProvider((ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  return dataSource.watchPendingReviews();
});

/// Provider for approving review requests and creating the post
final approveReviewProvider = Provider((ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  final postController = ref.watch(postControllerProvider.notifier);

  return ({
    required String reviewId,
    required String adminId,
    String? reviewNotes,
  }) async {
    // Step 1: Get the review request to extract post data
    final review = await dataSource.getReviewRequest(reviewId);

    // Step 2: Approve the review
    await dataSource.approveReview(
      reviewId,
      adminId,
      reviewNotes,
    );

    // Step 3: Create the post if it's a post-type review
    if (review.contentType == 'post' &&
        review.communityId != null &&
        review.forumId != null &&
        review.title != null) {
      await postController.createNewPost(
        communityId: review.communityId!,
        forumId: review.forumId!,
        authorId: review.userId,
        authorName: review.authorName ?? 'Unbekannt',
        authorPhotoUrl: review.authorPhotoUrl,
        title: review.title!,
        content: review.content,
      );
    }
  };
});

/// Provider for rejecting review requests and deleting the content
final rejectReviewProvider = Provider((ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  final postController = ref.watch(postControllerProvider.notifier);
  final commentController = ref.watch(commentControllerProvider.notifier);
  final postDataSource = ref.watch(postRemoteDataSourceProvider);

  return ({
    required String reviewId,
    required String adminId,
    String? reviewNotes,
  }) async {
    // Step 1: Get the review request to extract content data
    final review = await dataSource.getReviewRequest(reviewId);

    // Step 2: Delete the actual content (post or comment) if contentId exists
    if (review.contentId != null) {
      if (review.contentType == 'post' &&
          review.communityId != null &&
          review.forumId != null) {
        // Delete the post
        await postController.deleteExistingPost(
          review.communityId!,
          review.forumId!,
          review.contentId!,
        );
      } else if (review.contentType == 'comment' &&
          review.communityId != null &&
          review.forumId != null &&
          review.postId != null) {
        // Delete the comment
        await commentController.deleteExistingComment(
          communityId: review.communityId!,
          forumId: review.forumId!,
          postId: review.postId!,
          commentId: review.contentId!,
          postDataSource: postDataSource,
        );
      }
    }

    // Step 3: Reject/Delete the review request
    await dataSource.rejectReview(
      reviewId,
      adminId,
      reviewNotes,
    );
  };
});