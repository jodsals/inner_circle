import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

/// Comment model for data layer
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.communityId,
    required super.forumId,
    required super.postId,
    required super.authorId,
    required super.authorName,
    super.authorPhotoUrl,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    super.isEdited,
  });

  /// Create CommentModel from Firestore document
  factory CommentModel.fromFirestore(
    DocumentSnapshot doc,
    String communityId,
    String forumId,
    String postId,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentModel(
      id: doc.id,
      communityId: communityId,
      forumId: forumId,
      postId: postId,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEdited: data['isEdited'] as bool? ?? false,
    );
  }

  /// Convert CommentModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
    };
  }

  /// Create CommentModel from Comment entity
  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      communityId: comment.communityId,
      forumId: comment.forumId,
      postId: comment.postId,
      authorId: comment.authorId,
      authorName: comment.authorName,
      authorPhotoUrl: comment.authorPhotoUrl,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      isEdited: comment.isEdited,
    );
  }
}
