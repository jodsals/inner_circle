import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membership_model.dart';

/// Remote data source for membership operations
abstract class MembershipRemoteDataSource {
  Future<MembershipModel> joinCommunity({
    required String userId,
    required String communityId,
  });

  Future<void> leaveCommunity({
    required String userId,
    required String communityId,
  });

  Future<bool> isMember({
    required String userId,
    required String communityId,
  });

  Stream<List<String>> getUserCommunities(String userId);

  Stream<List<String>> getCommunityMembers(String communityId);
}

/// Firebase implementation of MembershipRemoteDataSource
class FirebaseMembershipRemoteDataSource
    implements MembershipRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseMembershipRemoteDataSource(this.firestore);

  @override
  Future<MembershipModel> joinCommunity({
    required String userId,
    required String communityId,
  }) async {
    final membershipId = '$userId\_$communityId';
    final membershipData = {
      'id': membershipId,
      'userId': userId,
      'communityId': communityId,
      'joinedAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('memberships')
        .doc(membershipId)
        .set(membershipData);

    // Increment community member count
    await firestore.collection('communities').doc(communityId).update({
      'memberCount': FieldValue.increment(1),
    });

    return MembershipModel(
      id: membershipId,
      userId: userId,
      communityId: communityId,
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<void> leaveCommunity({
    required String userId,
    required String communityId,
  }) async {
    final membershipId = '$userId\_$communityId';

    await firestore.collection('memberships').doc(membershipId).delete();

    // Decrement community member count
    await firestore.collection('communities').doc(communityId).update({
      'memberCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<bool> isMember({
    required String userId,
    required String communityId,
  }) async {
    final membershipId = '$userId\_$communityId';
    // Force server fetch to avoid cache issues
    final doc = await firestore
        .collection('memberships')
        .doc(membershipId)
        .get(const GetOptions(source: Source.server));
    return doc.exists;
  }

  @override
  Stream<List<String>> getUserCommunities(String userId) {
    return firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()['communityId'] as String).toList());
  }

  @override
  Stream<List<String>> getCommunityMembers(String communityId) {
    return firestore
        .collection('memberships')
        .where('communityId', isEqualTo: communityId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()['userId'] as String).toList());
  }
}
