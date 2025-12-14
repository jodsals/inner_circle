import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

/// Abstract remote data source for posts
abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts(String communityId, String forumId);
  Future<PostModel> getPost(String communityId, String forumId, String postId);
  Future<PostModel> createPost({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  });
  Future<PostModel> updatePost({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  });
  Future<void> deletePost(String communityId, String forumId, String postId);
  Stream<List<PostModel>> watchPosts(String communityId, String forumId);
  Future<void> incrementCommentCount(
      String communityId, String forumId, String postId);
  Future<void> decrementCommentCount(
      String communityId, String forumId, String postId);
}

/// Implementation of post remote data source
class FirebasePostRemoteDataSource implements PostRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebasePostRemoteDataSource(this.firestore);

  CollectionReference _postsCollection(String communityId, String forumId) =>
      firestore
          .collection('communities')
          .doc(communityId)
          .collection('forums')
          .doc(forumId)
          .collection('posts');

  @override
  Future<List<PostModel>> getPosts(String communityId, String forumId) async {
    try {
      final snapshot = await _postsCollection(communityId, forumId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc, communityId, forumId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get posts: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get posts: $e');
    }
  }

  @override
  Future<PostModel> getPost(
      String communityId, String forumId, String postId) async {
    try {
      final doc =
          await _postsCollection(communityId, forumId).doc(postId).get();

      if (!doc.exists) {
        throw const NotFoundException('Post not found');
      }

      return PostModel.fromFirestore(doc, communityId, forumId);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get post: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get post: $e');
    }
  }

  @override
  Future<PostModel> createPost({
    required String communityId,
    required String forumId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String title,
    required String content,
  }) async {
    try {
      // Create post document
      final docRef = await _postsCollection(communityId, forumId).add({
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'title': title,
        'content': content,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'isEdited': false,
      });

      // Get the created document
      final doc = await docRef.get();
      return PostModel.fromFirestore(doc, communityId, forumId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create post: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> updatePost({
    required String communityId,
    required String forumId,
    required String postId,
    String? title,
    String? content,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;

      await _postsCollection(communityId, forumId).doc(postId).update(updateData);

      // Get the updated document
      final doc =
          await _postsCollection(communityId, forumId).doc(postId).get();
      return PostModel.fromFirestore(doc, communityId, forumId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update post: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(
      String communityId, String forumId, String postId) async {
    try {
      // Delete all comments in this post
      final commentsSnapshot = await _postsCollection(communityId, forumId)
          .doc(postId)
          .collection('comments')
          .get();

      for (final commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }

      // Delete post document
      await _postsCollection(communityId, forumId).doc(postId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete post: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  @override
  Stream<List<PostModel>> watchPosts(String communityId, String forumId) {
    try {
      return _postsCollection(communityId, forumId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc, communityId, forumId))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch posts: $e');
    }
  }

  @override
  Future<void> incrementCommentCount(
      String communityId, String forumId, String postId) async {
    try {
      await _postsCollection(communityId, forumId).doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to increment comment count: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to increment comment count: $e');
    }
  }

  @override
  Future<void> decrementCommentCount(
      String communityId, String forumId, String postId) async {
    try {
      await _postsCollection(communityId, forumId).doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to decrement comment count: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to decrement comment count: $e');
    }
  }
}
