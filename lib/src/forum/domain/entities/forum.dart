import 'package:equatable/equatable.dart';

/// Forum entity representing a forum in the domain layer
class Forum extends Equatable {
  final String id;
  final String communityId;
  final String title;
  final DateTime createdAt;

  const Forum({
    required this.id,
    required this.communityId,
    required this.title,
    required this.createdAt,
  });

  /// Create a copy of this forum with updated fields
  Forum copyWith({
    String? id,
    String? communityId,
    String? title,
    DateTime? createdAt,
  }) {
    return Forum(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        communityId,
        title,
        createdAt,
      ];

  @override
  String toString() => 'Forum(id: $id, title: $title, communityId: $communityId)';
}