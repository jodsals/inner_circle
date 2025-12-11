import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/forum.dart';

/// Data Transfer Object for Forum
class ForumModel extends Forum {
  const ForumModel({
    required super.id,
    required super.communityId,
    required super.title,
    required super.createdAt,
  });

  /// Create ForumModel from Firestore DocumentSnapshot
  factory ForumModel.fromFirestore(DocumentSnapshot doc, String communityId) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumModel(
      id: doc.id,
      communityId: communityId,
      title: data['title'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create ForumModel from Map
  factory ForumModel.fromMap(Map<String, dynamic> map, String id, String communityId) {
    return ForumModel(
      id: id,
      communityId: communityId,
      title: map['title'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'communityId': communityId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory ForumModel.fromEntity(Forum forum) {
    return ForumModel(
      id: forum.id,
      communityId: forum.communityId,
      title: forum.title,
      createdAt: forum.createdAt,
    );
  }

  /// Create a copy with updated fields
  @override
  ForumModel copyWith({
    String? id,
    String? communityId,
    String? title,
    DateTime? createdAt,
  }) {
    return ForumModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}