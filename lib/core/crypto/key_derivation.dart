import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:pointycastle/export.dart';
import 'package:path_provider/path_provider.dart';

/// PBKDF2-HMAC-SHA256 key derivation for the Isar database encryption key.
///
/// Derives a 32-byte AES-256 key from the user's Master PIN.
/// The salt is randomly generated on first use and persisted to disk
/// (NOT inside Isar, to avoid a chicken-and-egg problem).
class KeyDerivationService {
  static const int _keyLength = 32; // 256 bits
  static const int _saltLength = 16; // 128 bits
  static const int _iterations = 15000;
  static const String _saltFileName = '.vitavault_salt';

  /// Derive a 32-byte AES-256 key from the given [pin].
  ///
  /// Runs PBKDF2 synchronously (15k iterations is fast enough for main thread).
  /// The result is strictly guaranteed to be exactly 32 bytes.
  Future<Uint8List> deriveKey(String pin) async {
    final salt = await _getOrCreateSalt();

    final params = Pbkdf2Parameters(salt, _iterations, _keyLength);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(params);

    final pinBytes = Uint8List.fromList(utf8.encode(pin));
    final rawKey = derivator.process(pinBytes);

    // Zero-fill the pin bytes immediately.
    for (var i = 0; i < pinBytes.length; i++) {
      pinBytes[i] = 0;
    }

    // Guarantee exactly 32 bytes for Isar AES-256 key.
    if (rawKey.length == _keyLength) return rawKey;
    final key = Uint8List(_keyLength);
    key.setRange(0, rawKey.length.clamp(0, _keyLength), rawKey);
    return key;
  }

  /// Verify that [pin] produces a key matching the stored verification hash.
  Future<bool> verifyPin(String pin) async {
    final verificationFile = await _getVerificationFile();
    if (!await verificationFile.exists()) return false;

    final storedHash = await verificationFile.readAsString();
    final key = await deriveKey(pin);
    final currentHash = _hashKey(key);

    // Zero-fill the derived key immediately after hashing.
    _zeroFill(key);

    return storedHash == currentHash;
  }

  /// Store a verification hash for the initial PIN setup.
  /// Called once when the user first creates their Master PIN.
  Future<void> storeVerificationHash(String pin) async {
    final key = await deriveKey(pin);
    final hash = _hashKey(key);
    _zeroFill(key);

    final file = await _getVerificationFile();
    await file.writeAsString(hash);
  }

  /// Check if a Master PIN has been set up.
  Future<bool> isPinConfigured() async {
    final file = await _getVerificationFile();
    return file.exists();
  }

  /// Read the raw PBKDF2 salt bytes from disk (for capsule export).
  Future<Uint8List> getSalt() async {
    final saltFile = await _getSaltFile();
    if (!await saltFile.exists()) {
      throw StateError('No salt file found. Vault not initialized.');
    }
    return Uint8List.fromList(await saltFile.readAsBytes());
  }

  /// Overwrite the local PBKDF2 salt with an imported one (for capsule restore).
  Future<void> overwriteSalt(Uint8List salt) async {
    final saltFile = await _getSaltFile();
    await saltFile.writeAsBytes(salt, flush: true);
  }

  // ── Private Helpers ──

  String _hashKey(Uint8List key) {
    final digest = SHA256Digest();
    final hash = digest.process(key);
    return base64Encode(hash);
  }

  Future<Uint8List> _getOrCreateSalt() async {
    final saltFile = await _getSaltFile();

    if (await saltFile.exists()) {
      final bytes = await saltFile.readAsBytes();
      return Uint8List.fromList(bytes);
    }

    // Generate a cryptographically secure random salt.
    final secureRandom = SecureRandom('Fortuna')
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List<int>.generate(32, (_) => Random.secure().nextInt(256)),
          ),
        ),
      );

    final salt = secureRandom.nextBytes(_saltLength);
    await saltFile.writeAsBytes(salt);
    return salt;
  }

  Future<File> _getSaltFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_saltFileName');
  }

  Future<File> _getVerificationFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}.vitavault_pin_verify');
  }

  /// Securely zero-fill a Uint8List to prevent key material lingering in RAM.
  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
