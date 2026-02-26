import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Ed25519-based cryptographic license verification for desktop platforms.
///
/// License keys have the format: `PAYLOAD.SIGNATURE_BASE64`
/// where PAYLOAD is the signed message and SIGNATURE_BASE64 is the
/// Ed25519 signature of that payload, base64-encoded.
///
/// The Founder's public key is hardcoded — only keys signed by the
/// corresponding private key will pass verification.
class LicenseService {
  LicenseService._();

  /// Founder's Ed25519 public key (base64).
  static const _publicKeyBase64 =
      'zn9+i8olcr4MjpT4g0AzF4InS7Irey+d/0EY4pH5Uk0=';

  /// Verify a desktop license key using Ed25519 signature verification.
  ///
  /// Returns `true` only if the key contains a mathematically valid
  /// Ed25519 signature. Returns `false` for any malformed or invalid key.
  static Future<bool> verifyDesktopLicense(String licenseKey) async {
    try {
      final trimmed = licenseKey.trim();
      if (trimmed.isEmpty) return false;

      // Split into payload and signature at the LAST dot.
      // The payload may contain dots (e.g. email addresses), so we
      // must use lastIndexOf to isolate the base64 signature suffix.
      final lastDotIndex = trimmed.lastIndexOf('.');
      if (lastDotIndex < 1 || lastDotIndex == trimmed.length - 1) {
        debugPrint('[LicenseService] Invalid format: no dot separator');
        return false;
      }

      final payload = trimmed.substring(0, lastDotIndex);
      final signatureBase64 = trimmed.substring(lastDotIndex + 1);

      // Decode components.
      final payloadBytes = utf8.encode(payload);
      final signatureBytes = base64Decode(signatureBase64);

      // Reconstruct the public key.
      final pubKeyBytes = base64Decode(_publicKeyBase64);
      final pubKey = SimplePublicKey(pubKeyBytes, type: KeyPairType.ed25519);

      // Verify the Ed25519 signature.
      final isValid = await Ed25519().verify(
        payloadBytes,
        signature: Signature(signatureBytes, publicKey: pubKey),
      );

      debugPrint('[LicenseService] Verification result: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('[LicenseService] Verification failed: $e');
      return false;
    }
  }
}
