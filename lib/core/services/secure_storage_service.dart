import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service für sichere Speicherung von sensiblen Daten
/// Nutzt Keychain (iOS) und Android Keystore
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Speichert einen Wert sicher
  Future<void> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write: ${e.toString()}');
    }
  }

  /// Liest einen gespeicherten Wert
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read: ${e.toString()}');
    }
  }

  /// Löscht einen gespeicherten Wert
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete: ${e.toString()}');
    }
  }

  /// Löscht alle gespeicherten Werte
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all: ${e.toString()}');
    }
  }

  /// Prüft ob ein Schlüssel existiert
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException(
          'Failed to check key existence: ${e.toString()}');
    }
  }

  /// Liest alle gespeicherten Schlüssel-Wert-Paare
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException('Failed to read all: ${e.toString()}');
    }
  }
}

/// Exception für SecureStorage Fehler
class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
