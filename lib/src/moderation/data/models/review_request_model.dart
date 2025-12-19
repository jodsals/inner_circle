import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review_request.dart';

/// Data model for ReviewRequest
class ReviewRequestModel extends ReviewRequest {
  const ReviewRequestModel({
    required super.id,
    required super.userId,
    required super.content,
    required super.contentType,
    super.communityId,
    super.forumId,
    super.title,
    super.authorName,
    super.authorPhotoUrl,
    required super.flagReasons,
    required super.confidenceScore,
    super.status,
    required super.requestedAt,
    super.reviewedAt,
    super.reviewedBy,
    super.reviewNotes,
  });

  /// Create from Firestore document
  factory ReviewRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewRequestModel(
      id: doc.id,
      userId: data['userId'] as String,
      content: data['content'] as String,
      contentType: data['contentType'] as String,
      communityId: data['communityId'] as String?,
      forumId: data['forumId'] as String?,
      title: data['title'] as String?,
      authorName: data['authorName'] as String?,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      flagReasons: (data['flagReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'] as String?,
      reviewNotes: data['reviewNotes'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'contentType': contentType,
      'communityId': communityId,
      'forumId': forumId,
      'title': title,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'flagReasons': flagReasons,
      'confidenceScore': confidenceScore,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
    };
  }

  /// Create from entity
  factory ReviewRequestModel.fromEntity(ReviewRequest request) {
    return ReviewRequestModel(
      id: request.id,
      userId: request.userId,
      content: request.content,
      contentType: request.contentType,
      communityId: request.communityId,
      forumId: request.forumId,
      title: request.title,
      authorName: request.authorName,
      authorPhotoUrl: request.authorPhotoUrl,
      flagReasons: request.flagReasons,
      confidenceScore: request.confidenceScore,
      status: request.status,
      requestedAt: request.requestedAt,
      reviewedAt: request.reviewedAt,
      reviewedBy: request.reviewedBy,
      reviewNotes: request.reviewNotes,
    );
  }

  @override
  ReviewRequestModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? contentType,
    String? communityId,
    String? forumId,
    String? title,
    String? authorName,
    String? authorPhotoUrl,
    List<String>? flagReasons,
    double? confidenceScore,
    String? status,
    DateTime? requestedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
  }) {
    return ReviewRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      communityId: communityId ?? this.communityId,
      forumId: forumId ?? this.forumId,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      flagReasons: flagReasons ?? this.flagReasons,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }
}
