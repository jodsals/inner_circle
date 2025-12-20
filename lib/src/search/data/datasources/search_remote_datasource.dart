import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../comment/data/models/comment_model.dart';
import '../../../post/data/models/post_model.dart';
import '../models/search_result_model.dart';

/// Abstract DataSource für Suche
abstract class SearchRemoteDataSource {
  Future<List<SearchResultModel>> search({
    required String query,
    required List<String> communityIds,
  });
}

/// Firebase Implementation des Search DataSource
class FirebaseSearchRemoteDataSource implements SearchRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSearchRemoteDataSource(this._firestore);

  @override
  Future<List<SearchResultModel>> search({
    required String query,
    required List<String> communityIds,
  }) async {
    try {
      if (communityIds.isEmpty) {
        return [];
      }

      final results = <SearchResultModel>[];
      final queryLower = query.toLowerCase();

      // Suche in Posts
      for (final communityId in communityIds) {
        // Hole alle Foren in der Community
        final forumsSnapshot = await _firestore
            .collection('communities')
            .doc(communityId)
            .collection('forums')
            .get();

        for (final forumDoc in forumsSnapshot.docs) {
          final forumId = forumDoc.id;

          // Hole alle Posts im Forum
          final postsSnapshot = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('forums')
              .doc(forumId)
              .collection('posts')
              .get();

          for (final doc in postsSnapshot.docs) {
            final post = PostModel.fromFirestore(doc, communityId, forumId);

            // Prüfe ob Suchbegriff in Titel oder Content vorkommt
            if (post.title.toLowerCase().contains(queryLower) ||
                post.content.toLowerCase().contains(queryLower)) {
              results.add(SearchResultModel.fromPost(post));
            }
          }
        }
      }

      // Suche in Comments
      for (final communityId in communityIds) {
        // Hole alle Foren in der Community
        final forumsSnapshot = await _firestore
            .collection('communities')
            .doc(communityId)
            .collection('forums')
            .get();

        for (final forumDoc in forumsSnapshot.docs) {
          final forumId = forumDoc.id;

          // Hole alle Posts im Forum
          final postsSnapshot = await _firestore
              .collection('communities')
              .doc(communityId)
              .collection('forums')
              .doc(forumId)
              .collection('posts')
              .get();

          for (final postDoc in postsSnapshot.docs) {
            final postId = postDoc.id;
            final post = PostModel.fromFirestore(postDoc, communityId, forumId);

            // Hole alle Comments des Posts
            final commentsSnapshot = await _firestore
                .collection('communities')
                .doc(communityId)
                .collection('forums')
                .doc(forumId)
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .get();

            for (final commentDoc in commentsSnapshot.docs) {
              final comment = CommentModel.fromFirestore(
                commentDoc,
                communityId,
                forumId,
                postId,
              );

              // Prüfe ob Suchbegriff im Content vorkommt
              if (comment.content.toLowerCase().contains(queryLower)) {
                results.add(
                  SearchResultModel.fromComment(comment, post.title),
                );
              }
            }
          }
        }
      }

      // Sortiere nach Datum (neueste zuerst)
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      throw ServerException('Suche fehlgeschlagen: ${e.toString()}');
    }
  }
}
