import 'package:equatable/equatable.dart';

/// Community entity representing a community in the domain layer
class Community extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? bannerImage;
  final int memberCount;
  final int likeCount;
  final DateTime createdAt;

  const Community({
    required this.id,
    required this.title,
    required this.description,
    this.bannerImage,
    this.memberCount = 0,
    this.likeCount = 0,
    required this.createdAt,
  });

  /// Create a copy of this community with updated fields
  Community copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerImage,
    int? memberCount,
    int? likeCount,
    DateTime? createdAt,
  }) {
    return Community(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      memberCount: memberCount ?? this.memberCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        bannerImage,
        memberCount,
        likeCount,
        createdAt,
      ];

  @override
  String toString() => 'Community(id: $id, title: $title)';
}