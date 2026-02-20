import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Session Vault — encrypts the Isar database file at rest using AES-256-GCM.
///
/// **At rest**: Only `.isar.aes` exists (encrypted).
/// **While unlocked**: Only `.isar` exists (plaintext, Isar has it open).
///
/// File format: `[12-byte nonce][ciphertext + 16-byte GCM tag]`
class VaultCryptoGuard {
  static const int _nonceLength = 12; // 96-bit GCM nonce

  /// Encrypt the plaintext `.isar` file into `.isar.aes` and shred the original.
  ///
  /// [key] must be exactly 32 bytes (AES-256).
  /// [isarPath] is the full path to the plaintext `.isar` file.
  static Future<void> sealVault(Uint8List key, String isarPath) async {
    final plainFile = File(isarPath);
    if (!plainFile.existsSync()) return; // Nothing to seal

    final sealedPath = '$isarPath.aes';
    final plainBytes = await plainFile.readAsBytes();

    // Generate a cryptographically secure 12-byte nonce
    final nonce = _secureRandomBytes(_nonceLength);

    // AES-256-GCM encrypt
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true, // encrypt
        AEADParameters(
          KeyParameter(key),
          128, // 128-bit auth tag
          nonce,
          Uint8List(0), // no AAD
        ),
      );

    final cipherBytes = cipher.process(Uint8List.fromList(plainBytes));

    // Write: [nonce][ciphertext+tag]
    final output = Uint8List(_nonceLength + cipherBytes.length);
    output.setRange(0, _nonceLength, nonce);
    output.setRange(_nonceLength, output.length, cipherBytes);

    final sealedFile = File(sealedPath);
    await sealedFile.writeAsBytes(output, flush: true);

    // Shred the plaintext .isar file
    await _shredFile(plainFile);

    // Also shred the .isar.lock file if present
    final lockFile = File('$isarPath.lock');
    if (lockFile.existsSync()) {
      try {
        lockFile.deleteSync();
      } catch (_) {}
    }
  }

  /// Decrypt `.isar.aes` back into `.isar` and shred the encrypted blob.
  ///
  /// [key] must be exactly 32 bytes (AES-256).
  /// [isarPath] is the desired output path for the plaintext `.isar` file.
  ///
  /// Returns `true` if decryption was performed, `false` if no sealed vault exists.
  static Future<bool> unsealVault(Uint8List key, String isarPath) async {
    final sealedPath = '$isarPath.aes';
    final sealedFile = File(sealedPath);
    if (!sealedFile.existsSync()) return false; // No sealed vault

    final raw = await sealedFile.readAsBytes();
    if (raw.length < _nonceLength + 16) {
      // File too small to contain nonce + GCM tag — corrupted
      return false;
    }

    final nonce = Uint8List.sublistView(raw, 0, _nonceLength);
    final cipherBytes = Uint8List.sublistView(raw, _nonceLength);

    // AES-256-GCM decrypt
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false, // decrypt
        AEADParameters(
          KeyParameter(key),
          128, // 128-bit auth tag
          nonce,
          Uint8List(0), // no AAD
        ),
      );

    final plainBytes = cipher.process(cipherBytes);

    // Write the decrypted .isar file
    final plainFile = File(isarPath);
    await plainFile.writeAsBytes(plainBytes, flush: true);

    // Shred the encrypted .aes blob
    try {
      await sealedFile.delete();
    } catch (_) {}

    return true;
  }

  /// Overwrite a file with zeros before deleting (secure shred).
  static Future<void> _shredFile(File file) async {
    try {
      final length = await file.length();
      // Overwrite with zeros in 64 KB chunks
      final raf = await file.open(mode: FileMode.write);
      final chunk = Uint8List(64 * 1024);
      var remaining = length;
      while (remaining > 0) {
        final writeSize = remaining > chunk.length ? chunk.length : remaining;
        await raf.writeFrom(chunk, 0, writeSize);
        remaining -= writeSize;
      }
      await raf.close();
      await file.delete();
    } catch (_) {
      // Best-effort shred — fall back to simple delete
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  static Uint8List _secureRandomBytes(int length) {
    final rng = SecureRandom('Fortuna')
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List<int>.generate(32, (_) => Random.secure().nextInt(256)),
          ),
        ),
      );
    return rng.nextBytes(length);
  }
}
