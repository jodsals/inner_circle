import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/membership.dart';

/// Membership model for data layer
class MembershipModel extends Membership {
  const MembershipModel({
    required super.id,
    required super.userId,
    required super.communityId,
    required super.joinedAt,
  });

  /// Create from Firestore document
  factory MembershipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MembershipModel(
      id: doc.id,
      userId: data['userId'] as String,
      communityId: data['communityId'] as String,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'communityId': communityId,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  /// Create from domain entity
  factory MembershipModel.fromEntity(Membership membership) {
    return MembershipModel(
      id: membership.id,
      userId: membership.userId,
      communityId: membership.communityId,
      joinedAt: membership.joinedAt,
    );
  }

  /// Convert to domain entity
  Membership toEntity() {
    return Membership(
      id: id,
      userId: userId,
      communityId: communityId,
      joinedAt: joinedAt,
    );
  }
}
