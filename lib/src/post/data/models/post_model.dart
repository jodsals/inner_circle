import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post.dart';

/// Post model for data layer
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.communityId,
    required super.forumId,
    required super.authorId,
    required super.authorName,
    super.authorPhotoUrl,
    required super.title,
    required super.content,
    super.likesCount,
    super.commentsCount,
    required super.createdAt,
    super.updatedAt,
    super.isEdited,
  });

  /// Create PostModel from Firestore document
  factory PostModel.fromFirestore(
    DocumentSnapshot doc,
    String communityId,
    String forumId,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      communityId: communityId,
      forumId: forumId,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      title: data['title'] as String,
      content: data['content'] as String,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEdited: data['isEdited'] as bool? ?? false,
    );
  }

  /// Convert PostModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'content': content,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
    };
  }

  /// Create PostModel from Post entity
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      communityId: post.communityId,
      forumId: post.forumId,
      authorId: post.authorId,
      authorName: post.authorName,
      authorPhotoUrl: post.authorPhotoUrl,
      title: post.title,
      content: post.content,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      isEdited: post.isEdited,
    );
  }
}
