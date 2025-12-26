import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_info.dart';
import '../services/secure_storage_service.dart';
import '../services/encryption_service.dart';
// ============================================================================
// Firebase Providers
// ============================================================================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Storage instance provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// ============================================================================
// Core Providers
// ============================================================================

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Secure storage service provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Encryption service provider
///
/// Verwendet AES-256 Verschlüsselung für sensible Daten
/// Der Encryption Key kann über Environment Variable konfiguriert werden
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  // In Production sollte der Key aus Secure Storage oder Environment Variable kommen
  const encryptionKey = String.fromEnvironment(
    'ENCRYPTION_KEY',
    defaultValue: '', // Leer = Standard-Key wird verwendet
  );

  return EncryptionService(
    encryptionKey: encryptionKey.isEmpty ? null : encryptionKey,
  );
});