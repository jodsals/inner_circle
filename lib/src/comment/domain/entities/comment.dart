import 'package:equatable/equatable.dart';

/// Comment entity representing a comment on a post in the domain layer
class Comment extends Equatable {
  final String id;
  final String communityId;
  final String forumId;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? parentId; // ID of the parent comment if this is a reply
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;

  const Comment({
    required this.id,
    required this.communityId,
    required this.forumId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.parentId,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
  });

  /// Create a copy of this comment with updated fields
  Comment copyWith({
    String? id,
    String? communityId,
    String? forumId,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return Comment(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      forumId: forumId ?? this.forumId,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
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
        postId,
        authorId,
        authorName,
        authorPhotoUrl,
        content,
        parentId,
        createdAt,
        updatedAt,
        isEdited,
      ];

  @override
  String toString() =>
      'Comment(id: $id, authorId: $authorId, postId: $postId)';
}
