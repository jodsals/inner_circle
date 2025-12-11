import 'package:equatable/equatable.dart';

import '../../domain/entities/community.dart';

/// State for community operations
class CommunityState extends Equatable {
  final List<Community> communities;
  final bool isLoading;
  final String? errorMessage;
  final Community? selectedCommunity;

  const CommunityState({
    this.communities = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCommunity,
  });

  /// Create initial state
  factory CommunityState.initial() => const CommunityState();

  /// Create loading state
  CommunityState copyWithLoading() => CommunityState(
        communities: communities,
        isLoading: true,
        selectedCommunity: selectedCommunity,
      );

  /// Create success state
  CommunityState copyWithSuccess({
    List<Community>? communities,
    Community? selectedCommunity,
  }) =>
      CommunityState(
        communities: communities ?? this.communities,
        isLoading: false,
        selectedCommunity: selectedCommunity ?? this.selectedCommunity,
      );

  /// Create error state
  CommunityState copyWithError(String message) => CommunityState(
        communities: communities,
        isLoading: false,
        errorMessage: message,
        selectedCommunity: selectedCommunity,
      );

  @override
  List<Object?> get props => [
        communities,
        isLoading,
        errorMessage,
        selectedCommunity,
      ];
}