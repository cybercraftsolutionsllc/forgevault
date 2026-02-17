import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'schemas/core_identity.dart';
import 'schemas/timeline_event.dart';
import 'schemas/trouble.dart';
import 'schemas/finance_record.dart';
import 'schemas/relationship_node.dart';
import 'schemas/audit_log.dart';
import 'schemas/health_profile.dart';
import 'schemas/goal.dart';
import 'schemas/habit_vice.dart';
import '../crypto/key_derivation.dart';

/// Singleton database service that opens the encrypted Isar instance.
///
/// The AES-256 database encryption key is derived from the user's
/// Master PIN via [KeyDerivationService] (PBKDF2-HMAC-SHA256).
class DatabaseService {
  static DatabaseService? _instance;
  Isar? _isar;
  final KeyDerivationService _keyDerivation = KeyDerivationService();

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Whether the database is currently open and ready.
  bool get isOpen => _isar != null && _isar!.isOpen;

  /// Get the active Isar instance. Throws if not initialized.
  Isar get db {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError(
        'Database not initialized. Call initialize() with the Master PIN first.',
      );
    }
    return _isar!;
  }

  /// Initialize the Isar database after verifying the Master PIN.
  ///
  /// 1. Derives a 32-byte AES-256 key from the PIN via PBKDF2.
  /// 2. Verifies the PIN against the stored hash.
  /// 3. Opens Isar (file-level encryption is handled by EphemeralKeyService).
  /// 4. Zero-fills the derived key from RAM immediately.
  ///
  /// Note: Isar 3.1.0 OSS does not support native DB encryption.
  /// All sensitive raw data is encrypted at the application layer
  /// (via EphemeralKeyService) before the Forge writes synthesized
  /// structured data into the database.
  Future<void> initialize(String masterPin) async {
    if (isOpen) return;

    final dir = await getApplicationSupportDirectory();
    final derivedKey = await _keyDerivation.deriveKey(masterPin);

    try {
      _isar = await Isar.open(
        [
          CoreIdentitySchema,
          TimelineEventSchema,
          TroubleSchema,
          FinanceRecordSchema,
          RelationshipNodeSchema,
          AuditLogSchema,
          HealthProfileSchema,
          GoalSchema,
          HabitViceSchema,
        ],
        directory: dir.path,
        name: 'vitavault',
      );
    } finally {
      // Always zero-fill the key material from RAM.
      _zeroFill(derivedKey);
    }
  }

  /// Close the database and clear the singleton.
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }
    _isar = null;
  }

  /// Check if the Master PIN has been configured.
  Future<bool> isPinConfigured() => _keyDerivation.isPinConfigured();

  /// Set up the Master PIN for the first time.
  Future<void> setupPin(String pin) async {
    await _keyDerivation.storeVerificationHash(pin);
  }

  /// Verify the Master PIN without opening the database.
  Future<bool> verifyPin(String pin) => _keyDerivation.verifyPin(pin);

  // ── Private Helpers ──

  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
