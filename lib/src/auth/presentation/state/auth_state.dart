import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Authentication state for the UI
class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.isAuthenticated = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Loading state
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Authenticated state
  factory AuthState.authenticated(User user) => AuthState(
        user: user,
        isAuthenticated: true,
      );

  /// Unauthenticated state
  factory AuthState.unauthenticated() => const AuthState();

  /// Error state
  factory AuthState.error(String message) => AuthState(
        errorMessage: message,
      );

  /// Create a copy with updated fields
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, user, isAuthenticated];

  @override
  String toString() => 'AuthState('
      'isLoading: $isLoading, '
      'isAuthenticated: $isAuthenticated, '
      'hasError: ${errorMessage != null}, '
      'user: ${user?.email})';
}
