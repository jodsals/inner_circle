import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/comment_model.dart';

/// Abstract remote data source for comments
abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(
      String communityId, String forumId, String postId);
  Future<CommentModel> getComment(
      String communityId, String forumId, String postId, String commentId);
  Future<CommentModel> createComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? parentId,
  });
  Future<CommentModel> updateComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  });
  Future<void> deleteComment(
      String communityId, String forumId, String postId, String commentId);
  Stream<List<CommentModel>> watchComments(
      String communityId, String forumId, String postId);
}

/// Implementation of comment remote data source
class FirebaseCommentRemoteDataSource implements CommentRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseCommentRemoteDataSource(this.firestore);

  CollectionReference _commentsCollection(
          String communityId, String forumId, String postId) =>
      firestore
          .collection('communities')
          .doc(communityId)
          .collection('forums')
          .doc(forumId)
          .collection('posts')
          .doc(postId)
          .collection('comments');

  @override
  Future<List<CommentModel>> getComments(
      String communityId, String forumId, String postId) async {
    try {
      final snapshot = await _commentsCollection(communityId, forumId, postId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) =>
              CommentModel.fromFirestore(doc, communityId, forumId, postId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get comments: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get comments: $e');
    }
  }

  @override
  Future<CommentModel> getComment(String communityId, String forumId,
      String postId, String commentId) async {
    try {
      final doc = await _commentsCollection(communityId, forumId, postId)
          .doc(commentId)
          .get();

      if (!doc.exists) {
        throw const NotFoundException('Comment not found');
      }

      return CommentModel.fromFirestore(doc, communityId, forumId, postId);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get comment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get comment: $e');
    }
  }

  @override
  Future<CommentModel> createComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? parentId,
  }) async {
    try {
      // Create comment document
      final docRef =
          await _commentsCollection(communityId, forumId, postId).add({
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'parentId': parentId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'isEdited': false,
      });

      // Get the created document
      final doc = await docRef.get();
      return CommentModel.fromFirestore(doc, communityId, forumId, postId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create comment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create comment: $e');
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String communityId,
    required String forumId,
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      await _commentsCollection(communityId, forumId, postId)
          .doc(commentId)
          .update({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });

      // Get the updated document
      final doc = await _commentsCollection(communityId, forumId, postId)
          .doc(commentId)
          .get();
      return CommentModel.fromFirestore(doc, communityId, forumId, postId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update comment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String communityId, String forumId, String postId,
      String commentId) async {
    try {
      await _commentsCollection(communityId, forumId, postId)
          .doc(commentId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete comment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete comment: $e');
    }
  }

  @override
  Stream<List<CommentModel>> watchComments(
      String communityId, String forumId, String postId) {
    try {
      return _commentsCollection(communityId, forumId, postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) =>
                CommentModel.fromFirestore(doc, communityId, forumId, postId))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch comments: $e');
    }
  }
}
