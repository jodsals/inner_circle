import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/review_request_model.dart';

/// Abstract remote data source for review requests
abstract class ReviewRemoteDataSource {
  Future<String> createReviewRequest(ReviewRequestModel request);
  Future<List<ReviewRequestModel>> getPendingReviews();
  Stream<List<ReviewRequestModel>> watchPendingReviews();
  Future<ReviewRequestModel> getReviewRequest(String id);
  Future<void> approveReview(String id, String reviewedBy, String? notes);
  Future<void> rejectReview(String id, String reviewedBy, String? notes);
}

/// Implementation of review remote data source
class FirebaseReviewRemoteDataSource implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseReviewRemoteDataSource(this.firestore);

  CollectionReference get _reviewsCollection =>
      firestore.collection('reviewRequests');

  @override
  Future<String> createReviewRequest(ReviewRequestModel request) async {
    try {
      final docRef = await _reviewsCollection.add(request.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create review request: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create review request: $e');
    }
  }

  @override
  Future<List<ReviewRequestModel>> getPendingReviews() async {
    try {
      final snapshot = await _reviewsCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewRequestModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get pending reviews: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get pending reviews: $e');
    }
  }

  @override
  Stream<List<ReviewRequestModel>> watchPendingReviews() {
    try {
      return _reviewsCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ReviewRequestModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw ServerException('Failed to watch pending reviews: $e');
    }
  }

  @override
  Future<ReviewRequestModel> getReviewRequest(String id) async {
    try {
      final doc = await _reviewsCollection.doc(id).get();

      if (!doc.exists) {
        throw const NotFoundException('Review request not found');
      }

      return ReviewRequestModel.fromFirestore(doc);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get review request: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get review request: $e');
    }
  }

  @override
  Future<void> approveReview(
    String id,
    String reviewedBy,
    String? notes,
  ) async {
    try {
      // Delete the review request after approval
      await _reviewsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to approve review: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to approve review: $e');
    }
  }

  @override
  Future<void> rejectReview(
    String id,
    String reviewedBy,
    String? notes,
  ) async {
    try {
      // Delete the review request after rejection
      await _reviewsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to reject review: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to reject review: $e');
    }
  }
}
