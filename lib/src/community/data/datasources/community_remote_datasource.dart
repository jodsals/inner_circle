import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/community_model.dart';

/// Abstract remote data source for communities
abstract class CommunityRemoteDataSource {
  Future<List<CommunityModel>> getCommunities();
  Future<CommunityModel> getCommunity(String id);
  Future<CommunityModel> createCommunity({
    required String title,
    required String description,
    String? bannerImagePath,
  });
  Future<CommunityModel> updateCommunity({
    required String id,
    String? title,
    String? description,
    String? bannerImagePath,
  });
  Future<void> deleteCommunity(String id);
  Stream<List<CommunityModel>> watchCommunities();

  // Like operations
  Future<void> likeCommunity({required String userId, required String communityId});
  Future<void> unlikeCommunity({required String userId, required String communityId});
  Future<bool> isLiked({required String userId, required String communityId});
}

/// Implementation of community remote data source
class FirebaseCommunityRemoteDataSource implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseCommunityRemoteDataSource(this.firestore, this.storage);

  CollectionReference get _communitiesCollection =>
      firestore.collection('communities');

  @override
  Future<List<CommunityModel>> getCommunities() async {
    try {
      final snapshot = await _communitiesCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommunityModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get communities: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get communities: $e');
    }
  }

  @override
  Future<CommunityModel> getCommunity(String id) async {
    try {
      final doc = await _communitiesCollection.doc(id).get();

      if (!doc.exists) {
        throw const NotFoundException('Community not found');
      }

      return CommunityModel.fromFirestore(doc);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get community: $e');
    }
  }

  @override
  Future<CommunityModel> createCommunity({
    required String title,
    required String description,
    String? bannerImagePath,
  }) async {
    try {
      // Upload banner image if provided
      String? bannerImageUrl;
      if (bannerImagePath != null) {
        bannerImageUrl = await _uploadBannerImage(bannerImagePath);
      }

      // Create community document
      final docRef = await _communitiesCollection.add({
        'title': title,
        'description': description,
        'bannerImage': bannerImageUrl,
        'memberCount': 0,
        'likeCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Get the created document
      final doc = await docRef.get();
      return CommunityModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create community: $e');
    }
  }

  @override
  Future<CommunityModel> updateCommunity({
    required String id,
    String? title,
    String? description,
    String? bannerImagePath,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;

      // Upload new banner image if provided
      if (bannerImagePath != null) {
        final bannerImageUrl = await _uploadBannerImage(bannerImagePath);
        updateData['bannerImage'] = bannerImageUrl;

        // Delete old banner image
        final oldDoc = await _communitiesCollection.doc(id).get();
        final oldData = oldDoc.data() as Map<String, dynamic>?;
        final oldImageUrl = oldData?['bannerImage'] as String?;
        if (oldImageUrl != null) {
          await _deleteBannerImage(oldImageUrl);
        }
      }

      await _communitiesCollection.doc(id).update(updateData);

      // Get the updated document
      final doc = await _communitiesCollection.doc(id).get();
      return CommunityModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update community: $e');
    }
  }

  @override
  Future<void> deleteCommunity(String id) async {
    try {
      // Get community to delete banner image
      final doc = await _communitiesCollection.doc(id).get();
      final data = doc.data() as Map<String, dynamic>?;
      final bannerImageUrl = data?['bannerImage'] as String?;

      // Delete banner image if exists
      if (bannerImageUrl != null) {
        await _deleteBannerImage(bannerImageUrl);
      }

      // Delete all forums in this community
      final forumsSnapshot =
          await _communitiesCollection.doc(id).collection('forums').get();
      for (final forumDoc in forumsSnapshot.docs) {
        await forumDoc.reference.delete();
      }

      // Delete community document
      await _communitiesCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete community: $e');
    }
  }

  @override
  Stream<List<CommunityModel>> watchCommunities() {
    try {
      return _communitiesCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CommunityModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to watch communities: $e');
    }
  }

  /// Upload banner image to Firebase Storage
  Future<String> _uploadBannerImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = storage.ref().child('communities/banners/$fileName');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to upload banner image: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to upload banner image: $e');
    }
  }

  /// Delete banner image from Firebase Storage
  Future<void> _deleteBannerImage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting images
      // Image might already be deleted or URL might be invalid
    }
  }

  // ============================================
  // LIKE OPERATIONS
  // ============================================

  @override
  Future<void> likeCommunity({
    required String userId,
    required String communityId,
  }) async {
    try {
      final likeId = '${userId}_$communityId';

      // Create like document
      await firestore.collection('communityLikes').doc(likeId).set({
        'id': likeId,
        'userId': userId,
        'communityId': communityId,
        'likedAt': FieldValue.serverTimestamp(),
      });

      // Increment like count
      await _communitiesCollection.doc(communityId).update({
        'likeCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to like community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to like community: $e');
    }
  }

  @override
  Future<void> unlikeCommunity({
    required String userId,
    required String communityId,
  }) async {
    try {
      final likeId = '${userId}_$communityId';

      // Delete like document
      await firestore.collection('communityLikes').doc(likeId).delete();

      // Decrement like count
      await _communitiesCollection.doc(communityId).update({
        'likeCount': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to unlike community: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to unlike community: $e');
    }
  }

  @override
  Future<bool> isLiked({
    required String userId,
    required String communityId,
  }) async {
    try {
      final likeId = '${userId}_$communityId';
      final doc = await firestore
          .collection('communityLikes')
          .doc(likeId)
          .get(const GetOptions(source: Source.server));
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to check like status: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to check like status: $e');
    }
  }
}