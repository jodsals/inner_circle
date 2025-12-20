import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Abstract interface for remote authentication data source
abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> registerWithEmail(String email, String password, [String? displayName]);
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginAnonymously();
  Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateDisplayName(String displayName);
  Future<void> updatePhotoUrl(String photoUrl);
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount();
  Future<void> reauthenticateWithPassword(String password);
}

/// Implementation of AuthRemoteDataSource using Firebase
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn? _googleSignIn;

  FirebaseAuthRemoteDataSource(
    this._firebaseAuth,
    this._firestore, [
    this._googleSignIn,
  ]);

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Get user profile from Firestore to get role
      try {
        final profileDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (profileDoc.exists) {
          return UserModel.fromFirestore(profileDoc);
        }
      } catch (e) {
        // If Firestore fetch fails, return user with default role
      }

      return UserModel.fromFirebaseAuth(firebaseUser);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final profileDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (profileDoc.exists) {
        return UserModel.fromFirestore(profileDoc);
      }
    } catch (e) {
      // Fallback to Firebase Auth user
    }

    return UserModel.fromFirebaseAuth(firebaseUser);
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password, [String? displayName]) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('User creation failed');
      }

      // Set display name in Firebase Auth if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Get updated user after setting display name
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthException('Failed to get updated user');
      }

      // Create user profile in Firestore
      final userModel = UserModel.fromFirebaseAuth(updatedUser);
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Login failed');
      }

      // Update last login timestamp
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      // Fetch full user profile
      final profileDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (profileDoc.exists) {
        return UserModel.fromFirestore(profileDoc);
      }

      return UserModel.fromFirebaseAuth(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> loginAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();

      if (credential.user == null) {
        throw const AuthException('Anonymous login failed');
      }

      return UserModel.fromFirebaseAuth(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Anonymous login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // TODO: Implement Google Sign-In after verifying google_sign_in package version
    // This requires proper Google Sign-In configuration in Firebase Console
    throw const AuthException(
      'Google Sign-In ist derzeit nicht verfügbar. '
      'Bitte verwenden Sie Email/Passwort-Anmeldung.',
    );

    /* Example implementation (uncomment after configuring):
    try {
      // Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled');
      }

      // Obtain auth details
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Google login failed');
      }

      // Check if profile exists, create if not
      final profileDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!profileDoc.exists) {
        final userModel = UserModel.fromFirebaseAuth(userCredential.user!);
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());
        return userModel;
      } else {
        // Update last login
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLogin': FieldValue.serverTimestamp()});
        return UserModel.fromFirestore(profileDoc);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Google login failed: ${e.toString()}');
    }
    */
  }

  @override
  Future<void> logout() async {
    try {
      final futures = <Future<void>>[
        _firebaseAuth.signOut(),
      ];

      // Only sign out of Google if GoogleSignIn is configured
      if (_googleSignIn != null) {
        futures.add(_googleSignIn!.signOut());
      }

      await Future.wait(futures);
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');

      await user.updateDisplayName(displayName);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'displayName': displayName});
    } catch (e) {
      throw AuthException('Update display name failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');

      await user.updatePhotoURL(photoUrl);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': photoUrl});
    } catch (e) {
      throw AuthException('Update photo URL failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');

      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Bitte melden Sie sich erneut an, um Ihr Passwort zu ändern',
        );
      }
      if (e.code == 'weak-password') {
        throw const AuthException('Das neue Passwort ist zu schwach');
      }
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');

      // Delete user profile from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Bitte melden Sie sich erneut an, um Ihr Konto zu löschen',
        );
      }
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Account deletion failed: ${e.toString()}');
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');
      if (user.email == null) throw const AuthException('No email found');

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Reauthentication failed: ${e.toString()}');
    }
  }

  /// Map Firebase Auth exceptions to app exceptions
  AuthException _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('Kein Benutzer mit dieser E-Mail gefunden');
      case 'wrong-password':
        return const AuthException('Falsches Passwort');
      case 'email-already-in-use':
        return const AuthException('Diese E-Mail wird bereits verwendet');
      case 'weak-password':
        return const AuthException('Das Passwort ist zu schwach');
      case 'invalid-email':
        return const AuthException('Ungültige E-Mail-Adresse');
      case 'user-disabled':
        return const AuthException('Dieser Account wurde deaktiviert');
      case 'too-many-requests':
        return const AuthException(
          'Zu viele Anmeldeversuche. Bitte versuchen Sie es später erneut',
        );
      case 'operation-not-allowed':
        return const AuthException('Diese Anmeldemethode ist nicht aktiviert');
      case 'requires-recent-login':
        return const AuthException(
          'Bitte melden Sie sich erneut an, um fortzufahren',
        );
      default:
        return AuthException('Authentifizierungsfehler: ${e.message ?? e.code}');
    }
  }
}
