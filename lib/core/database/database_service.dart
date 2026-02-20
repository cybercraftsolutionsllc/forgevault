import 'dart:io';

import 'package:flutter/foundation.dart';

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
import 'schemas/medical_ledger.dart';
import 'schemas/career_ledger.dart';
import 'schemas/asset_ledger.dart';
import 'schemas/relational_web.dart';
import 'schemas/psyche_profile.dart';
import '../crypto/key_derivation.dart';
import '../crypto/vault_crypto_guard.dart';

/// Singleton database service that opens the encrypted Isar instance.
///
/// The AES-256 database encryption key is derived from the user's
/// Master PIN via [KeyDerivationService] (PBKDF2-HMAC-SHA256).
class DatabaseService {
  static DatabaseService? _instance;
  Isar? _isar;
  String? _isarPath; // Cached for seal/unseal operations
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
  /// 2. Unseals the at-rest encrypted vault (`.isar.aes` → `.isar`).
  /// 3. Opens Isar with the decrypted database file.
  /// 4. Zero-fills the derived key from RAM immediately.
  ///
  /// Session Vault Protocol: The `.isar` file only exists in plaintext
  /// while the app is unlocked. At rest, only `.isar.aes` survives.
  Future<void> initialize(String masterPin) async {
    if (isOpen) return;

    final dir = await getApplicationSupportDirectory();
    final derivedKey = await _keyDerivation.deriveKey(masterPin);
    _isarPath = '${dir.path}${Platform.pathSeparator}vitavault.isar';

    try {
      // Unseal the at-rest encrypted vault (no-op on first run)
      await VaultCryptoGuard.unsealVault(derivedKey, _isarPath!);

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
          MedicalLedgerSchema,
          CareerLedgerSchema,
          AssetLedgerSchema,
          RelationalWebSchema,
          PsycheProfileSchema,
        ],
        directory: dir.path,
        name: 'vitavault',
      );
    } finally {
      // Always zero-fill the key material from RAM.
      _zeroFill(derivedKey);
    }
  }

  /// Close the database without encrypting. Use [sealAndClose] for secure close.
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }
    _isar = null;
  }

  /// Securely close the database and encrypt it at rest.
  ///
  /// 1. Closes Isar.
  /// 2. Encrypts `.isar` → `.isar.aes` via AES-256-GCM.
  /// 3. Shreds the plaintext `.isar` file.
  ///
  /// The [masterPin] is needed to re-derive the encryption key.
  Future<void> sealAndClose(String masterPin) async {
    final derivedKey = await _keyDerivation.deriveKey(masterPin);
    try {
      // Close Isar first to release the file lock
      if (_isar != null && _isar!.isOpen) {
        await _isar!.close();
      }
      _isar = null;

      // Give Windows time to release the OS file lock
      await Future.delayed(const Duration(milliseconds: 300));

      // Encrypt the database at rest
      if (_isarPath != null) {
        await VaultCryptoGuard.sealVault(derivedKey, _isarPath!);
      }
    } finally {
      _zeroFill(derivedKey);
    }
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

  /// Watch the first MedicalLedger record.
  Stream<MedicalLedger?> watchMedicalLedger() {
    return db.medicalLedgers
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch the first CareerLedger record.
  Stream<CareerLedger?> watchCareerLedger() {
    return db.careerLedgers
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch the first AssetLedger record.
  Stream<AssetLedger?> watchAssetLedger() {
    return db.assetLedgers
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch the first RelationalWeb record.
  Stream<RelationalWeb?> watchRelationalWeb() {
    return db.relationalWebs
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }

  /// Watch the first PsycheProfile record.
  Stream<PsycheProfile?> watchPsycheProfile() {
    return db.psycheProfiles
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
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
      buffer.writeln('  Identity [ID: ${identity.id}] - ${identity.fullName}');
      if (identity.location.isNotEmpty) {
        buffer.writeln('  Location: ${identity.location}');
      }
      if ((identity.immutableTraits ?? []).isNotEmpty) {
        buffer.writeln('  Traits: ${identity.immutableTraits!.join(', ')}');
      }
      if ((identity.jobHistory ?? []).isNotEmpty) {
        buffer.writeln('  Job History: ${identity.jobHistory!.join(', ')}');
      }
      if ((identity.locationHistory ?? []).isNotEmpty) {
        buffer.writeln(
          '  Location History: ${identity.locationHistory!.join(', ')}',
        );
      }
      if ((identity.educationHistory ?? []).isNotEmpty) {
        buffer.writeln('  Education: ${identity.educationHistory!.join(', ')}');
      }
      if ((identity.familyLineage ?? []).isNotEmpty) {
        buffer.writeln(
          '  Family Lineage: ${identity.familyLineage!.join(', ')}',
        );
      }
      buffer.writeln();
    }

    // All Troubles (including resolved, so LLM can match by ID)
    final troubles = await db.troubles.where().findAll();
    if (troubles.isNotEmpty) {
      buffer.writeln('TROUBLES:');
      for (final t in troubles) {
        buffer.writeln(
          '  Trouble [ID: ${t.id}] - ${t.title} (Resolved: ${t.isResolved})',
        );
      }
      buffer.writeln();
    }

    // Goals (all, including completed)
    final goals = await db.goals.where().findAll();
    if (goals.isNotEmpty) {
      buffer.writeln('GOALS:');
      for (final g in goals) {
        buffer.writeln(
          '  Goal [ID: ${g.id}] - ${g.title} (${g.progress}% complete)',
        );
      }
      buffer.writeln();
    }

    // Habits & Vices
    final habits = await db.habitVices.where().findAll();
    if (habits.isNotEmpty) {
      buffer.writeln('HABITS / VICES:');
      for (final h in habits) {
        final type = h.isVice ? 'Vice' : 'Habit';
        buffer.writeln(
          '  Habit [ID: ${h.id}] - ${h.name} ($type, ${h.frequency})',
        );
      }
      buffer.writeln();
    }

    // Timeline Events
    final events = await db.timelineEvents.where().findAll();
    if (events.isNotEmpty) {
      buffer.writeln('TIMELINE EVENTS:');
      for (final e in events) {
        buffer.writeln(
          '  Event [ID: ${e.id}] - ${e.title} (${e.eventDate.toIso8601String().split('T').first})',
        );
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
      if ((health.labResults ?? []).isNotEmpty) {
        buffer.writeln('  Lab Results: ${health.labResults!.join(', ')}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Calculate bio progress (0.0–1.0) based on populated fields.
  ///
  /// Strict validation: a field only counts if it is non-null, trimmed
  /// non-empty, and not a placeholder like 'Unknown' or 'N/A'.
  /// Diagnostic debugPrints are intentionally left in for debugging.
  ///
  /// Field count breakdown:
  ///   Identity:       9 fields
  ///   Health:         5 fields
  ///   Medical:        8 fields
  ///   Career:         6 fields
  ///   Assets:         6 fields
  ///   RelationalWeb:  5 fields
  ///   Psyche:        10 fields (8 lists + enneagram + mbti)
  ///   Troubles:       1 (has any)
  ///   Goals:          1 (has any)
  ///   Finances:       1 (has any)
  ///   Relationships:  1 (has any)
  ///   HabitsVices:    1 (has any)
  ///   Timeline:       1 (has any)
  ///   ─────────────────────
  ///   TOTAL:         55 fields
  Future<double> calculateBioProgress() async {
    double score = 0;
    const int totalFields = 55;

    bool isValid(String? value) {
      if (value == null) return false;
      final v = value.trim().toLowerCase();
      if (v.isEmpty) return false;
      const placeholders = {
        'unknown',
        'n/a',
        'none',
        '-',
        '—',
        'null',
        '',
        '[]',
        '{}',
        'n\\a',
      };
      return !placeholders.contains(v);
    }

    bool listValid(List<String>? list) {
      if (list == null || list.isEmpty) return false;
      // At least one element must pass isValid
      return list.any((e) => isValid(e));
    }

    void award(String field, bool pass, [String? rawValue]) {
      if (pass) {
        score++;
        debugPrint('BioMath: +1  $field  (value: ${rawValue ?? "OK"})');
      }
    }

    // ── Identity fields (9) ──
    final identity = await db.coreIdentitys.where().findFirst();
    debugPrint('BioMath: CoreIdentity record exists = ${identity != null}');
    if (identity != null) {
      award('fullName', isValid(identity.fullName), identity.fullName);
      award(
        'dateOfBirth',
        identity.dateOfBirth != null,
        '${identity.dateOfBirth}',
      );
      award('location', isValid(identity.location), identity.location);
      award(
        'immutableTraits',
        listValid(identity.immutableTraits),
        '${identity.immutableTraits}',
      );
      award(
        'digitalFootprint',
        listValid(identity.digitalFootprint),
        '${identity.digitalFootprint}',
      );
      award(
        'jobHistory',
        listValid(identity.jobHistory),
        '${identity.jobHistory}',
      );
      award(
        'locationHistory',
        listValid(identity.locationHistory),
        '${identity.locationHistory}',
      );
      award(
        'educationHistory',
        listValid(identity.educationHistory),
        '${identity.educationHistory}',
      );
      award(
        'familyLineage',
        listValid(identity.familyLineage),
        '${identity.familyLineage}',
      );
    }

    // ── Health fields (5) ──
    final health = await db.healthProfiles.where().findFirst();
    debugPrint('BioMath: HealthProfile record exists = ${health != null}');
    if (health != null) {
      award('bloodType', isValid(health.bloodType), health.bloodType);
      award('allergies', listValid(health.allergies), '${health.allergies}');
      award(
        'medications',
        listValid(health.medications),
        '${health.medications}',
      );
      award('conditions', listValid(health.conditions), '${health.conditions}');
      award('labResults', listValid(health.labResults), '${health.labResults}');
    }

    // ── Medical Ledger fields (8) ──
    final medical = await db.medicalLedgers.where().findFirst();
    debugPrint('BioMath: MedicalLedger record exists = ${medical != null}');
    if (medical != null) {
      award('surgeries', listValid(medical.surgeries));
      award('genetics', listValid(medical.genetics));
      award('vitalBaselines', listValid(medical.vitalBaselines));
      award('visionRx', listValid(medical.visionRx));
      award('familyMedicalHistory', listValid(medical.familyMedicalHistory));
      award('bloodwork', listValid(medical.bloodwork));
      award('immunizations', listValid(medical.immunizations));
      award('dentalHistory', listValid(medical.dentalHistory));
    }

    // ── Career Ledger fields (6) ──
    final career = await db.careerLedgers.where().findFirst();
    debugPrint('BioMath: CareerLedger record exists = ${career != null}');
    if (career != null) {
      award('career.jobs', listValid(career.jobs));
      award('career.degrees', listValid(career.degrees));
      award('career.certifications', listValid(career.certifications));
      award('career.clearances', listValid(career.clearances));
      award('career.skills', listValid(career.skills));
      award('career.projects', listValid(career.projects));
    }

    // ── Asset Ledger fields (6) ──
    final assets = await db.assetLedgers.where().findFirst();
    debugPrint('BioMath: AssetLedger record exists = ${assets != null}');
    if (assets != null) {
      award('assets.realEstate', listValid(assets.realEstate));
      award('assets.vehicles', listValid(assets.vehicles));
      award('assets.digitalAssets', listValid(assets.digitalAssets));
      award('assets.insurance', listValid(assets.insurance));
      award('assets.investments', listValid(assets.investments));
      award('assets.valuables', listValid(assets.valuables));
    }

    // ── RelationalWeb fields (5) ──
    final relWeb = await db.relationalWebs.where().findFirst();
    debugPrint('BioMath: RelationalWeb record exists = ${relWeb != null}');
    if (relWeb != null) {
      award('relWeb.family', listValid(relWeb.family));
      award('relWeb.mentors', listValid(relWeb.mentors));
      award('relWeb.adversaries', listValid(relWeb.adversaries));
      award('relWeb.colleagues', listValid(relWeb.colleagues));
      award('relWeb.friends', listValid(relWeb.friends));
    }

    // ── PsycheProfile fields (10) ──
    final psyche = await db.psycheProfiles.where().findFirst();
    debugPrint('BioMath: PsycheProfile record exists = ${psyche != null}');
    if (psyche != null) {
      award('psyche.beliefs', listValid(psyche.beliefs));
      award('psyche.personality', listValid(psyche.personality));
      award('psyche.fears', listValid(psyche.fears));
      award('psyche.motivations', listValid(psyche.motivations));
      award('psyche.enneagram', isValid(psyche.enneagram));
      award('psyche.mbti', isValid(psyche.mbti));
      award('psyche.strengths', listValid(psyche.strengths));
      award('psyche.weaknesses', listValid(psyche.weaknesses));
      // Two additional personality dimensions
      award(
        'psyche.fears+motivations.depth',
        (psyche.fears?.length ?? 0) >= 2 &&
            (psyche.motivations?.length ?? 0) >= 2,
      );
      award(
        'psyche.strengths+weaknesses.depth',
        (psyche.strengths?.length ?? 0) >= 2 &&
            (psyche.weaknesses?.length ?? 0) >= 2,
      );
    }

    // ── Collection existence checks (6) ──
    final troubles = await db.troubles.where().findAll();
    award(
      'troubles.exists',
      troubles.any((t) => isValid(t.title) || isValid(t.detailText)),
    );

    final goalsList = await db.goals.where().findAll();
    award('goals.exists', goalsList.any((g) => isValid(g.title)));

    final financesList = await db.financeRecords.where().findAll();
    award(
      'finances.exists',
      financesList.any((f) => isValid(f.assetOrDebtName)),
    );

    final relationshipsList = await db.relationshipNodes.where().findAll();
    award(
      'relationships.exists',
      relationshipsList.any((r) => isValid(r.personName)),
    );

    final habits = await db.habitVices.where().findAll();
    award('habitsVices.exists', habits.any((h) => isValid(h.name)));

    final timeline = await db.timelineEvents.where().findAll();
    award('timeline.exists', timeline.any((e) => isValid(e.title)));

    final result = (score / totalFields).clamp(0.0, 1.0);
    debugPrint(
      'BioMath: TOTAL = $score / $totalFields = ${(result * 100).toStringAsFixed(1)}%',
    );
    return result;
  }

  // ── Deletion Helpers ──

  Future<void> deleteGoal(int id) async {
    await db.writeTxn(() async => db.goals.delete(id));
  }

  Future<void> deleteHabitVice(int id) async {
    await db.writeTxn(() async => db.habitVices.delete(id));
  }

  Future<void> deleteTrouble(int id) async {
    await db.writeTxn(() async => db.troubles.delete(id));
  }

  Future<void> deleteTimelineEvent(int id) async {
    await db.writeTxn(() async => db.timelineEvents.delete(id));
  }
  // ── Incineration ──

  /// Scorched-earth database destruction with retry and rename fallback.
  ///
  /// 1. `db.clear()` — vaporize all records internally.
  /// 2. `db.close(deleteFromDisk: true)` — Isar's built-in shredder.
  /// 3. Retry loop: 3 attempts × 500 ms to force-delete `.isar` + `.lock`.
  /// 4. Fallback: rename locked `.isar` → `.isar.trash`, zero-fill it.
  /// 5. Also delete `.isar.aes` (the sealed vault blob).
  Future<void> nukeDatabase() async {
    String? dbPath;
    try {
      if (_isar != null && _isar!.isOpen) {
        // Vaporize all data internally (bypasses OS file locks)
        await _isar!.writeTxn(() async => await _isar!.clear());
        dbPath = _isar!.path;
        await _isar!.close(deleteFromDisk: true);
      }
    } catch (_) {}

    _isar = null;
    dbPath ??= _isarPath;
    if (dbPath == null) return;

    // Retry loop: 3 attempts to delete the files
    for (var attempt = 0; attempt < 3; attempt++) {
      await Future.delayed(const Duration(milliseconds: 500));
      final dbFile = File(dbPath);
      final lockFile = File('$dbPath.lock');
      if (!dbFile.existsSync() && !lockFile.existsSync()) break;

      try {
        if (dbFile.existsSync()) dbFile.deleteSync();
      } catch (_) {}
      try {
        if (lockFile.existsSync()) lockFile.deleteSync();
      } catch (_) {}
    }

    // Fallback: if the file STILL exists, rename to .trash and zero-fill
    final dbFile = File(dbPath);
    if (dbFile.existsSync()) {
      try {
        final trashPath = '$dbPath.trash';
        await dbFile.rename(trashPath);
        final trashFile = File(trashPath);
        final length = await trashFile.length();
        final raf = await trashFile.open(mode: FileMode.write);
        final zeros = Uint8List(64 * 1024);
        var remaining = length;
        while (remaining > 0) {
          final w = remaining > zeros.length ? zeros.length : remaining;
          await raf.writeFrom(zeros, 0, w);
          remaining -= w;
        }
        await raf.close();
        await trashFile.delete();
      } catch (_) {}
    }

    // Shred the sealed vault (.aes) as well
    final aesFile = File('$dbPath.aes');
    if (aesFile.existsSync()) {
      try {
        await aesFile.delete();
      } catch (_) {}
    }

    _isarPath = null;
  }

  // ── Private Helpers ──

  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
