import 'package:equatable/equatable.dart';

/// Membership entity representing a user's membership in a community
class Membership extends Equatable {
  final String id;
  final String userId;
  final String communityId;
  final DateTime joinedAt;

  const Membership({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, userId, communityId, joinedAt];

  @override
  String toString() =>
      'Membership(userId: $userId, communityId: $communityId)';
}
