import 'package:equatable/equatable.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../../post/domain/entities/post.dart';

/// Enum für Suchergebnis-Typ
enum SearchResultType {
  post,
  comment,
}

/// Such-Ergebnis Entity
class SearchResult extends Equatable {
  final String id;
  final SearchResultType type;
  final String title;
  final String content;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final String communityId;
  final String forumId;
  final String? postId; // Für Comments: die Post-ID
  final Post? post; // Falls es ein Post ist
  final Comment? comment; // Falls es ein Comment ist

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorPhotoUrl,
    required this.createdAt,
    required this.communityId,
    required this.forumId,
    this.postId,
    this.post,
    this.comment,
  });

  /// Erstelle SearchResult aus einem Post
  factory SearchResult.fromPost(Post post) {
    return SearchResult(
      id: post.id,
      type: SearchResultType.post,
      title: post.title,
      content: post.content,
      authorName: post.authorName,
      authorPhotoUrl: post.authorPhotoUrl,
      createdAt: post.createdAt,
      communityId: post.communityId,
      forumId: post.forumId,
      postId: post.id,
      post: post,
    );
  }

  /// Erstelle SearchResult aus einem Comment
  factory SearchResult.fromComment(Comment comment, String postTitle) {
    return SearchResult(
      id: comment.id,
      type: SearchResultType.comment,
      title: 'Kommentar zu: $postTitle',
      content: comment.content,
      authorName: comment.authorName,
      authorPhotoUrl: comment.authorPhotoUrl,
      createdAt: comment.createdAt,
      communityId: comment.communityId,
      forumId: comment.forumId,
      postId: comment.postId,
      comment: comment,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        content,
        authorName,
        authorPhotoUrl,
        createdAt,
        communityId,
        forumId,
        postId,
      ];
}
