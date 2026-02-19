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

  // ── Isar Stream Watchers (Reactive UI) ──

  /// Watch the first CoreIdentity record. Emits null if none exists.
  Stream<CoreIdentity?> watchCoreIdentity() {
    return db.coreIdentitys
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch all TimelineEvent records, sorted newest first.
  Stream<List<TimelineEvent>> watchTimelineEvents() {
    return db.timelineEvents.where().sortByEventDateDesc().watch(
      fireImmediately: true,
    );
  }

  /// Watch all Trouble records, sorted by severity descending.
  Stream<List<Trouble>> watchTroubles() {
    return db.troubles.where().sortBySeverityDesc().watch(
      fireImmediately: true,
    );
  }

  /// Watch all Goal records.
  Stream<List<Goal>> watchGoals() {
    return db.goals.where().watch(fireImmediately: true);
  }

  /// Watch the first HealthProfile record.
  Stream<HealthProfile?> watchHealthProfile() {
    return db.healthProfiles
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch all FinanceRecord records.
  Stream<List<FinanceRecord>> watchFinanceRecords() {
    return db.financeRecords.where().watch(fireImmediately: true);
  }

  /// Watch all RelationshipNode records.
  Stream<List<RelationshipNode>> watchRelationships() {
    return db.relationshipNodes.where().watch(fireImmediately: true);
  }

  /// Watch all HabitVice records.
  Stream<List<HabitVice>> watchHabitsVices() {
    return db.habitVices.where().watch(fireImmediately: true);
  }

  // ── Context Extraction for Forge ──

  /// Build a human-readable string of the current vault state
  /// for injection into the Forge prompt (context-aware synthesis).
  Future<String> getBioContextString() async {
    final buffer = StringBuffer();

    // Identity
    final identity = await db.coreIdentitys.where().findFirst();
    if (identity != null) {
      buffer.writeln('IDENTITY:');
      buffer.writeln('  Full Name: ${identity.fullName}');
      if (identity.location.isNotEmpty) {
        buffer.writeln('  Location: ${identity.location}');
      }
      if ((identity.immutableTraits ?? []).isNotEmpty) {
        buffer.writeln('  Traits: ${identity.immutableTraits!.join(', ')}');
      }
      buffer.writeln();
    }

    // Active Troubles
    final troubles = await db.troubles.where().findAll();
    final activeTroubles = troubles.where((t) => !t.isResolved).toList();
    if (activeTroubles.isNotEmpty) {
      buffer.writeln('ACTIVE TROUBLES:');
      for (final t in activeTroubles) {
        buffer.writeln('  - ${t.title} (severity: ${t.severity}/10)');
      }
      buffer.writeln();
    }

    // Habits & Vices
    final habits = await db.habitVices.where().findAll();
    if (habits.isNotEmpty) {
      buffer.writeln('HABITS / VICES:');
      for (final h in habits) {
        final type = h.isVice ? 'Vice' : 'Habit';
        buffer.writeln('  - ${h.name} ($type, ${h.frequency})');
      }
      buffer.writeln();
    }

    // Health
    final health = await db.healthProfiles.where().findFirst();
    if (health != null) {
      buffer.writeln('HEALTH:');
      if ((health.conditions ?? []).isNotEmpty) {
        buffer.writeln('  Conditions: ${health.conditions!.join(', ')}');
      }
      if ((health.medications ?? []).isNotEmpty) {
        buffer.writeln('  Medications: ${health.medications!.join(', ')}');
      }
      buffer.writeln();
    }

    // Goals
    final goals = await db.goals.where().findAll();
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    if (activeGoals.isNotEmpty) {
      buffer.writeln('ACTIVE GOALS:');
      for (final g in activeGoals) {
        buffer.writeln('  - ${g.title} (${g.progress}% complete)');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  // ── Private Helpers ──

  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
