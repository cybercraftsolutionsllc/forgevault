import 'dart:typed_data';
import 'dart:math';

import 'package:pointycastle/export.dart';

/// Ephemeral AES-256-CBC encryption service for the Vacuum → Purge pipeline.
///
/// Generates single-use AES-256 keys that exist ONLY in RAM.
/// After the Forge synthesizes data, the key is zero-filled,
/// rendering the encrypted sandbox file mathematically unrecoverable.
class EphemeralKeyService {
  Uint8List? _activeKey;
  Uint8List? _activeIv;

  /// Whether an ephemeral key is currently loaded in memory.
  bool get hasActiveKey => _activeKey != null;

  /// Generate a fresh single-use AES-256 key and IV.
  /// Returns the key bytes (caller should NOT persist them).
  Uint8List generateKey() {
    if (_activeKey != null) {
      throw StateError(
        'An ephemeral key is already active. '
        'Destroy it before generating a new one.',
      );
    }

    final secureRandom = _createSecureRandom();
    _activeKey = secureRandom.nextBytes(32); // 256-bit key
    _activeIv = secureRandom.nextBytes(16); // 128-bit IV for CBC

    return Uint8List.fromList(_activeKey!);
  }

  /// Encrypt [plainData] using the active ephemeral key (AES-256-CBC, PKCS7).
  Uint8List encrypt(Uint8List plainData) {
    _requireActiveKey();

    final cipher = PaddedBlockCipher('AES/CBC/PKCS7')
      ..init(
        true, // encrypt
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(_activeKey!), _activeIv!),
          null,
        ),
      );

    return cipher.process(plainData);
  }

  /// Decrypt [cipherData] using the active ephemeral key.
  Uint8List decrypt(Uint8List cipherData) {
    _requireActiveKey();

    final cipher = PaddedBlockCipher('AES/CBC/PKCS7')
      ..init(
        false, // decrypt
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(_activeKey!), _activeIv!),
          null,
        ),
      );

    return cipher.process(cipherData);
  }

  /// Cryptographic Erasure: zero-fill the key and IV from RAM.
  ///
  /// After this call, any data encrypted with this key is
  /// mathematically unrecoverable — the Purge is complete.
  void destroy() {
    if (_activeKey != null) {
      _zeroFill(_activeKey!);
      _activeKey = null;
    }
    if (_activeIv != null) {
      _zeroFill(_activeIv!);
      _activeIv = null;
    }
  }

  /// Get the IV needed to prepend/store alongside encrypted data.
  Uint8List get currentIv {
    _requireActiveKey();
    return Uint8List.fromList(_activeIv!);
  }

  // ── Private Helpers ──

  void _requireActiveKey() {
    if (_activeKey == null || _activeIv == null) {
      throw StateError('No active ephemeral key. Call generateKey() first.');
    }
  }

  FortunaRandom _createSecureRandom() {
    final secureRandom = FortunaRandom();
    secureRandom.seed(
      KeyParameter(
        Uint8List.fromList(
          List<int>.generate(32, (_) => Random.secure().nextInt(256)),
        ),
      ),
    );
    return secureRandom;
  }

  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
