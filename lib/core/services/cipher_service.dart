import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;
import 'package:encrypt/encrypt.dart' as enc;

/// Aegis Cipher Engine — AES-256-GCM End-to-End Encryption.
///
/// Uses PBKDF2-HMAC-SHA256 (210,000 iterations) to derive a 256-bit key
/// from a plaintext password + a cryptographically secure random salt.
/// Generates a fresh 12-byte IV per encryption call.
///
/// Output format: JSON envelope `{salt, iv, ciphertext}` —
/// salt and IV stored unencrypted so the key can be re-derived on import.
class CipherService {
  CipherService._();
  static final CipherService instance = CipherService._();

  /// PBKDF2 iteration count — OWASP 2024 minimum for HMAC-SHA256.
  static const int _pbkdf2Iterations = 210000;
  static const int _saltLength = 16; // 128-bit salt
  static const int _keyLength = 32; // 256-bit AES key

  /// Derive a 32-byte (256-bit) AES key from [password] + [salt]
  /// using PBKDF2-HMAC-SHA256 with 210,000 iterations.
  enc.Key _deriveKeyPbkdf2(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password.trim());

    // PBKDF2-HMAC-SHA256 manual implementation using dart:crypto
    Uint8List hi(Uint8List salt, int iterations, int blockIndex) {
      // U1 = PRF(password, salt || INT_32_BE(blockIndex))
      final blockBytes = Uint8List(4);
      blockBytes[0] = (blockIndex >> 24) & 0xFF;
      blockBytes[1] = (blockIndex >> 16) & 0xFF;
      blockBytes[2] = (blockIndex >> 8) & 0xFF;
      blockBytes[3] = blockIndex & 0xFF;

      final hmacSalt = Uint8List(salt.length + 4);
      hmacSalt.setRange(0, salt.length, salt);
      hmacSalt.setRange(salt.length, hmacSalt.length, blockBytes);

      var u = Uint8List.fromList(
        hash.Hmac(hash.sha256, passwordBytes).convert(hmacSalt).bytes,
      );
      final result = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(
          hash.Hmac(hash.sha256, passwordBytes).convert(u).bytes,
        );
        for (var j = 0; j < result.length; j++) {
          result[j] ^= u[j];
        }
      }
      return result;
    }

    // Derive enough blocks to fill _keyLength bytes
    final blocksNeeded = (_keyLength / 32).ceil();
    final derivedKey = Uint8List(_keyLength);
    var offset = 0;
    for (var block = 1; block <= blocksNeeded; block++) {
      final blockOutput = hi(salt, _pbkdf2Iterations, block);
      final copyLength = (offset + blockOutput.length > _keyLength)
          ? _keyLength - offset
          : blockOutput.length;
      derivedKey.setRange(offset, offset + copyLength, blockOutput);
      offset += copyLength;
    }

    return enc.Key(derivedKey);
  }

  /// Legacy key derivation — bare SHA-256 (for decrypting old backups only).
  enc.Key _deriveKeyLegacy(String password) {
    final keyBytes = hash.sha256.convert(utf8.encode(password.trim())).bytes;
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  /// Generate a cryptographically secure random salt.
  Uint8List _generateSalt() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_saltLength, (_) => rng.nextInt(256)),
    );
  }

  /// Encrypt [jsonPayload] with AES-256-GCM using a PBKDF2-derived key.
  ///
  /// Returns a **JSON string** containing `salt`, `iv`, and `ciphertext`
  /// as Base64 fields. A fresh salt and IV are generated per call.
  String encryptVault(String jsonPayload, String password) {
    final salt = _generateSalt();
    final key = _deriveKeyPbkdf2(password, salt);
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(jsonPayload, iv: iv);

    return jsonEncode({
      'salt': base64Encode(salt),
      'iv': iv.base64,
      'ciphertext': encrypted.base64,
    });
  }

  /// Decrypt a JSON-encoded `{salt, iv, ciphertext}` envelope back to
  /// plaintext JSON using a PBKDF2-derived key.
  ///
  /// Also supports legacy formats:
  /// - JSON `{iv, ciphertext}` (no salt → falls back to SHA-256 derivation)
  /// - Legacy `iv:ciphertext` colon-delimited format
  ///
  /// Throws [StateError] if the password is wrong, data was tampered with,
  /// or the artifact format is corrupted.
  String decryptVault(String encryptedString, String password) {
    final cleanPassword = password.trim();

    String? saltBase64;
    String ivBase64;
    String cipherBase64;

    // Try JSON first (new or previous format)
    try {
      final map = jsonDecode(encryptedString.trim()) as Map<String, dynamic>;
      saltBase64 = map['salt'] as String?;
      ivBase64 = map['iv'] as String;
      cipherBase64 = map['ciphertext'] as String;
    } catch (_) {
      // Fall back to legacy colon-delimited format
      final sanitized = encryptedString.replaceAll(
        RegExp(r'[^A-Za-z0-9+/=:]'),
        '',
      );
      final parts = sanitized.split(':');
      if (parts.length != 2) {
        throw StateError(
          'Corrupted Artifact Format — unable to parse .forge file.',
        );
      }
      ivBase64 = parts[0];
      cipherBase64 = parts[1];
    }

    final iv = enc.IV.fromBase64(ivBase64);
    final ciphertext = enc.Encrypted.fromBase64(cipherBase64);

    // Derive key: PBKDF2 if salt present, legacy SHA-256 otherwise
    final enc.Key key;
    if (saltBase64 != null) {
      final salt = base64Decode(saltBase64);
      key = _deriveKeyPbkdf2(cleanPassword, Uint8List.fromList(salt));
    } else {
      key = _deriveKeyLegacy(cleanPassword);
    }

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    try {
      return encrypter.decrypt(ciphertext, iv: iv);
    } catch (e) {
      throw StateError(
        'Decryption failed — wrong password or tampered payload.',
      );
    }
  }
}
