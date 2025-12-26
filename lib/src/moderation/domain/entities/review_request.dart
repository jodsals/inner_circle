import 'package:equatable/equatable.dart';

/// Request for manual review of flagged content
class ReviewRequest extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String contentType; // 'post' or 'comment'
  final String? contentId; // ID of the post or comment being reviewed
  final String? postId; // ID of the post (required for comments to enable deletion)
  final String? communityId;
  final String? forumId;
  final String? title; // Post title (only for contentType='post')
  final String? authorName; // Author display name
  final String? authorPhotoUrl; // Author photo URL
  final List<String> flagReasons;
  final double confidenceScore;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;

  const ReviewRequest({
    required this.id,
    required this.userId,
    required this.content,
    required this.contentType,
    this.contentId,
    this.postId,
    this.communityId,
    this.forumId,
    this.title,
    this.authorName,
    this.authorPhotoUrl,
    required this.flagReasons,
    required this.confidenceScore,
    this.status = 'pending',
    required this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
  });

  /// Check if review is still pending
  bool get isPending => status == 'pending';

  /// Check if review was approved
  bool get isApproved => status == 'approved';

  /// Check if review was rejected
  bool get isRejected => status == 'rejected';

  ReviewRequest copyWith({
    String? id,
    String? userId,
    String? content,
    String? contentType,
    String? contentId,
    String? postId,
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
    return ReviewRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      postId: postId ?? this.postId,
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

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        contentType,
        contentId,
        postId,
        communityId,
        forumId,
        title,
        authorName,
        authorPhotoUrl,
        flagReasons,
        confidenceScore,
        status,
        requestedAt,
        reviewedAt,
        reviewedBy,
        reviewNotes,
      ];

  @override
  String toString() => 'ReviewRequest(id: $id, status: $status, user: $userId)';
}
