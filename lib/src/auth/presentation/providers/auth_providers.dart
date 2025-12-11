import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import '../state/auth_state.dart';
import 'auth_controller.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Auth remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // TODO: Configure GoogleSignIn when implementing Google Sign-In feature
  // Passing null for now since Google Sign-In is not yet configured
  return FirebaseAuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    null, // GoogleSignIn will be added when the feature is implemented
  );
});

// ============================================================================
// Repositories
// ============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ============================================================================
// Use Cases
// ============================================================================

/// Login with email use case provider
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>((ref) {
  return LoginWithEmailUseCase(ref.watch(authRepositoryProvider));
});

/// Register with email use case provider
final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>((ref) {
  return RegisterWithEmailUseCase(ref.watch(authRepositoryProvider));
});

/// Logout use case provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Get current user use case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// ============================================================================
// Controllers
// ============================================================================

/// Auth controller provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginWithEmailUseCase: ref.watch(loginWithEmailUseCaseProvider),
    registerWithEmailUseCase: ref.watch(registerWithEmailUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});

// ============================================================================
// Stream Providers
// ============================================================================

/// Auth state changes stream provider
/// Listens to Firebase Auth state changes
final authStateChangesProvider = StreamProvider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current user provider
/// Returns the currently authenticated user or null
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.user;
});
