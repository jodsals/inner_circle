import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Abstract repository interface for authentication operations
/// This defines the contract that data layer must implement
/// The domain layer depends on this abstraction, not on concrete implementations
abstract class AuthRepository {
  /// Stream of authentication state changes
  /// Emits user when authenticated, null when not authenticated
  Stream<User?> get authStateChanges;

  /// Get currently authenticated user
  /// Returns null if not authenticated
  Future<Either<Failure, User?>> getCurrentUser();

  /// Register a new user with email and password
  /// Returns the created user on success
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Login with email and password
  /// Returns the authenticated user on success
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login anonymously
  /// Returns the anonymous user on success
  Future<Either<Failure, User>> loginAnonymously();

  /// Login with Google
  /// Returns the authenticated user on success
  Future<Either<Failure, User>> loginWithGoogle();

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update user display name
  Future<Either<Failure, void>> updateDisplayName(String displayName);

  /// Update user photo URL
  Future<Either<Failure, void>> updatePhotoUrl(String photoUrl);

  /// Update user password
  Future<Either<Failure, void>> updatePassword(String newPassword);

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Reauthenticate user with password (required for sensitive operations)
  Future<Either<Failure, void>> reauthenticateWithPassword(String password);
}
