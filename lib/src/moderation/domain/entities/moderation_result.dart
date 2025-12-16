import 'package:equatable/equatable.dart';

/// Result of AI content moderation
class ModerationResult extends Equatable {
  final bool isFlagged;
  final List<String> reasons;
  final String analysis;
  final double confidenceScore;

  const ModerationResult({
    required this.isFlagged,
    required this.reasons,
    required this.analysis,
    required this.confidenceScore,
  });

  /// Check if content is safe to post
  bool get isSafe => !isFlagged;

  /// Get primary reason for flagging
  String? get primaryReason => reasons.isNotEmpty ? reasons.first : null;

  @override
  List<Object?> get props => [
        isFlagged,
        reasons,
        analysis,
        confidenceScore,
      ];

  @override
  String toString() =>
      'ModerationResult(isFlagged: $isFlagged, reasons: $reasons, confidence: $confidenceScore)';
}