import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/reauthenticate_with_password.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/update_display_name.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/update_photo_url.dart';
import '../state/auth_state.dart';

/// Controller for authentication state and actions
class AuthController extends StateNotifier<AuthState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final RegisterWithEmailUseCase _registerWithEmailUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;
  final UpdatePhotoUrlUseCase _updatePhotoUrlUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ReauthenticateWithPasswordUseCase _reauthenticateWithPasswordUseCase;

  AuthController({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required RegisterWithEmailUseCase registerWithEmailUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdateDisplayNameUseCase updateDisplayNameUseCase,
    required UpdatePhotoUrlUseCase updatePhotoUrlUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required ReauthenticateWithPasswordUseCase reauthenticateWithPasswordUseCase,
  })  : _loginWithEmailUseCase = loginWithEmailUseCase,
        _registerWithEmailUseCase = registerWithEmailUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updateDisplayNameUseCase = updateDisplayNameUseCase,
        _updatePhotoUrlUseCase = updatePhotoUrlUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _reauthenticateWithPasswordUseCase = reauthenticateWithPasswordUseCase,
        super(AuthState.initial()) {
    // Check if user is already logged in
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    state = AuthState.loading();

    final result = await _getCurrentUserUseCase.execute();

    result.fold(
      (failure) {
        state = AuthState.unauthenticated();
      },
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.unauthenticated();
        }
      },
    );
  }

  /// Login with email and password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _loginWithEmailUseCase.execute(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Register with email and password
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _registerWithEmailUseCase.execute(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _logoutUseCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = AuthState.unauthenticated();
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh current user data from database
  Future<void> refreshUserData() async {
    final result = await _getCurrentUserUseCase.execute();

    result.fold(
      (failure) {
        // Keep current state on error
      },
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        }
      },
    );
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateDisplayNameUseCase.execute(displayName);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) async {
        state = state.copyWith(isLoading: false);
        await refreshUserData();
      },
    );
  }

  /// Update user photo URL
  Future<void> updatePhotoUrl(String photoUrl) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updatePhotoUrlUseCase.execute(photoUrl);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) async {
        state = state.copyWith(isLoading: false);
        await refreshUserData();
      },
    );
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updatePasswordUseCase.execute(newPassword);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteAccountUseCase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = AuthState.unauthenticated();
      },
    );
  }

  /// Reauthenticate user with password
  Future<void> reauthenticateWithPassword(String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _reauthenticateWithPasswordUseCase.execute(password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }
}
