import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/community.dart';

/// Data Transfer Object for Community
class CommunityModel extends Community {
  const CommunityModel({
    required super.id,
    required super.title,
    required super.description,
    super.bannerImage,
    super.memberCount,
    required super.createdAt,
  });

  /// Create CommunityModel from Firestore DocumentSnapshot
  factory CommunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      bannerImage: data['bannerImage'] as String?,
      memberCount: data['memberCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create CommunityModel from Map
  factory CommunityModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      bannerImage: map['bannerImage'] as String?,
      memberCount: map['memberCount'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'bannerImage': bannerImage,
      'memberCount': memberCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerImage': bannerImage,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory CommunityModel.fromEntity(Community community) {
    return CommunityModel(
      id: community.id,
      title: community.title,
      description: community.description,
      bannerImage: community.bannerImage,
      memberCount: community.memberCount,
      createdAt: community.createdAt,
    );
  }

  /// Create a copy with updated fields
  @override
  CommunityModel copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerImage,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}