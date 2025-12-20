import '../../../comment/domain/entities/comment.dart';
import '../../../post/domain/entities/post.dart';
import '../../domain/entities/search_result.dart';

/// Model für SearchResult
class SearchResultModel {
  final String id;
  final SearchResultType type;
  final String title;
  final String content;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final String communityId;
  final String forumId;
  final String? postId;
  final Post? post;
  final Comment? comment;

  SearchResultModel({
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

  /// Erstelle Model aus Post
  factory SearchResultModel.fromPost(Post post) {
    return SearchResultModel(
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

  /// Erstelle Model aus Comment
  factory SearchResultModel.fromComment(Comment comment, String postTitle) {
    return SearchResultModel(
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

  /// Konvertiere zu Entity
  SearchResult toEntity() {
    return SearchResult(
      id: id,
      type: type,
      title: title,
      content: content,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      createdAt: createdAt,
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      post: post,
      comment: comment,
    );
  }
}
