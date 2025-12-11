import 'package:equatable/equatable.dart';

import '../../domain/entities/forum.dart';

/// State for forum operations
class ForumState extends Equatable {
  final List<Forum> forums;
  final bool isLoading;
  final String? errorMessage;
  final Forum? selectedForum;
  final String? selectedCommunityId;

  const ForumState({
    this.forums = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedForum,
    this.selectedCommunityId,
  });

  /// Create initial state
  factory ForumState.initial() => const ForumState();

  /// Create loading state
  ForumState copyWithLoading() => ForumState(
        forums: forums,
        isLoading: true,
        selectedForum: selectedForum,
        selectedCommunityId: selectedCommunityId,
      );

  /// Create success state
  ForumState copyWithSuccess({
    List<Forum>? forums,
    Forum? selectedForum,
    String? selectedCommunityId,
  }) =>
      ForumState(
        forums: forums ?? this.forums,
        isLoading: false,
        selectedForum: selectedForum ?? this.selectedForum,
        selectedCommunityId: selectedCommunityId ?? this.selectedCommunityId,
      );

  /// Create error state
  ForumState copyWithError(String message) => ForumState(
        forums: forums,
        isLoading: false,
        errorMessage: message,
        selectedForum: selectedForum,
        selectedCommunityId: selectedCommunityId,
      );

  @override
  List<Object?> get props => [
        forums,
        isLoading,
        errorMessage,
        selectedForum,
        selectedCommunityId,
      ];
}