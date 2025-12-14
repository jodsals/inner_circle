import 'package:equatable/equatable.dart';

/// Post entity representing a forum post/question in the domain layer
class Post extends Equatable {
  final String id;
  final String communityId;
  final String forumId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String content;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;

  const Post({
    required this.id,
    required this.communityId,
    required this.forumId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.content,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
  });

  /// Create a copy of this post with updated fields
  Post copyWith({
    String? id,
    String? communityId,
    String? forumId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? title,
    String? content,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return Post(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      forumId: forumId ?? this.forumId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        communityId,
        forumId,
        authorId,
        authorName,
        authorPhotoUrl,
        title,
        content,
        likesCount,
        commentsCount,
        createdAt,
        updatedAt,
        isEdited,
      ];

  @override
  String toString() =>
      'Post(id: $id, title: $title, authorId: $authorId, forumId: $forumId)';
}
