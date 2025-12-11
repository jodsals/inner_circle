import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/forum_model.dart';

/// Abstract remote data source for forums
abstract class ForumRemoteDataSource {
  Future<List<ForumModel>> getForums(String communityId);
  Future<ForumModel> getForum(String communityId, String forumId);
  Future<ForumModel> createForum({
    required String communityId,
    required String title,
  });
  Future<ForumModel> updateForum({
    required String communityId,
    required String forumId,
    required String title,
  });
  Future<void> deleteForum(String communityId, String forumId);
  Stream<List<ForumModel>> watchForums(String communityId);
}

/// Implementation of forum remote data source
class FirebaseForumRemoteDataSource implements ForumRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseForumRemoteDataSource(this.firestore);

  CollectionReference _forumsCollection(String communityId) =>
      firestore.collection('communities').doc(communityId).collection('forums');

  @override
  Future<List<ForumModel>> getForums(String communityId) async {
    try {
      final snapshot = await _forumsCollection(communityId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ForumModel.fromFirestore(doc, communityId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get forums: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get forums: $e');
    }
  }

  @override
  Future<ForumModel> getForum(String communityId, String forumId) async {
    try {
      final doc = await _forumsCollection(communityId).doc(forumId).get();

      if (!doc.exists) {
        throw const NotFoundException('Forum not found');
      }

      return ForumModel.fromFirestore(doc, communityId);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get forum: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get forum: $e');
    }
  }

  @override
  Future<ForumModel> createForum({
    required String communityId,
    required String title,
  }) async {
    try {
      // Create forum document
      final docRef = await _forumsCollection(communityId).add({
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Get the created document
      final doc = await docRef.get();
      return ForumModel.fromFirestore(doc, communityId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create forum: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create forum: $e');
    }
  }

  @override
  Future<ForumModel> updateForum({
    required String communityId,
    required String forumId,
    required String title,
  }) async {
    try {
      await _forumsCollection(communityId).doc(forumId).update({
        'title': title,
      });

      // Get the updated document
      final doc = await _forumsCollection(communityId).doc(forumId).get();
      return ForumModel.fromFirestore(doc, communityId);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update forum: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update forum: $e');
    }
  }

  @override
  Future<void> deleteForum(String communityId, String forumId) async {
    try {
      await _forumsCollection(communityId).doc(forumId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete forum: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete forum: $e');
    }
  }

  @override
  Stream<List<ForumModel>> watchForums(String communityId) {
    try {
      return _forumsCollection(communityId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ForumModel.fromFirestore(doc, communityId))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch forums: $e');
    }
  }
}