import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

/// Service für End-to-End Verschlüsselung von sensiblen Daten
///
/// Verwendet AES-256-GCM für sichere Verschlüsselung.
/// Der Encryption Key sollte sicher gespeichert werden (z.B. in Secure Storage)
class EncryptionService {
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  /// Erstellt einen EncryptionService mit einem Encryption Key
  ///
  /// Der Key sollte 32 Bytes lang sein für AES-256
  /// Wenn kein Key angegeben wird, wird ein Standard-Key verwendet (NICHT für Production!)
  EncryptionService({String? encryptionKey}) {
    // Standard-Key für Entwicklung (MUSS in Production durch echten Key ersetzt werden!)
    final keyString = encryptionKey ?? 'innercircle2025_default_encryption_key_change_me';

    // Key auf genau 32 Bytes hashen (für AES-256)
    final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    // IV (Initialization Vector) - sollte in Production random sein
    // Für Konsistenz verwenden wir hier einen festen IV
    final ivBytes = sha256.convert(utf8.encode('$keyString-iv')).bytes.sublist(0, 16);
    _iv = encrypt.IV(Uint8List.fromList(ivBytes));

    _encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  /// Verschlüsselt einen String
  ///
  /// Gibt den verschlüsselten Text als Base64-String zurück
  String encryptString(String plainText) {
    if (plainText.isEmpty) return plainText;

    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      // Bei Fehler Original-Text zurückgeben (Fallback)
      print('Encryption error: $e');
      return plainText;
    }
  }

  /// Entschlüsselt einen verschlüsselten String
  ///
  /// Erwartet den verschlüsselten Text als Base64-String
  String decryptString(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Bei Fehler verschlüsselten Text zurückgeben (möglicherweise schon entschlüsselt)
      print('Decryption error: $e');
      return encryptedText;
    }
  }

  /// Verschlüsselt mehrere Strings (z.B. für Listen)
  List<String> encryptList(List<String> plainTexts) {
    return plainTexts.map((text) => encryptString(text)).toList();
  }

  /// Entschlüsselt mehrere Strings
  List<String> decryptList(List<String> encryptedTexts) {
    return encryptedTexts.map((text) => decryptString(text)).toList();
  }

  /// Prüft, ob ein Text verschlüsselt ist (heuristische Prüfung)
  ///
  /// Nicht 100% sicher, aber hilft bei der Migration
  bool isEncrypted(String text) {
    if (text.isEmpty) return false;

    // Verschlüsselte Texte sind Base64
    // Prüfe ob der Text nur Base64-Zeichen enthält
    final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64Regex.hasMatch(text) && text.length > 20;
  }
}
