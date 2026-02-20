import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';
import 'package:share_plus/share_plus.dart';

import '../crypto/key_derivation.dart';

import '../database/database_service.dart';
import '../database/schemas/core_identity.dart';
import '../database/schemas/timeline_event.dart';
import '../database/schemas/trouble.dart';
import '../database/schemas/finance_record.dart';
import '../database/schemas/relationship_node.dart';
import '../database/schemas/audit_log.dart';
import '../database/schemas/health_profile.dart';
import '../database/schemas/goal.dart';
import '../database/schemas/habit_vice.dart';
import '../database/schemas/medical_ledger.dart';
import '../database/schemas/career_ledger.dart';
import '../database/schemas/asset_ledger.dart';
import '../database/schemas/relational_web.dart';
import '../database/schemas/psyche_profile.dart';

/// The Encrypted Courier — Zero-Trust Multi-Device Sync (BYOS).
///
/// Bundles the entire Isar database into an AES-256-GCM encrypted file
/// (`vault_state.forgevault`) that can be placed in any OS-level sync
/// directory (iCloud Drive, Google Drive, OneDrive, etc.).
///
/// Encryption key is derived from the user's Master PIN via PBKDF2.
/// No cloud APIs. No OAuth. No Firebase. Pure filesystem sync.
class VaultSyncService {
  static const String _syncFileName = 'vault_state.forgevault';
  static const String _syncDirKey = 'ForgeVault_sync_directory';
  static const int _keyLength = 32; // AES-256
  static const int _saltLength = 16;
  static const int _pbkdf2Iterations = 100000;
  static const int _syncVersion = 1;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Sync Directory Management ──

  /// Let the user pick a sync directory via the native file picker.
  Future<String?> selectSyncDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Sync Directory',
    );

    if (result != null) {
      await _secureStorage.write(key: _syncDirKey, value: result);
    }

    return result;
  }

  /// Get the previously selected sync directory, or null.
  Future<String?> getSyncDirectory() async {
    return _secureStorage.read(key: _syncDirKey);
  }

  /// Clear the sync directory setting.
  Future<void> clearSyncDirectory() async {
    await _secureStorage.delete(key: _syncDirKey);
  }

  // ── Export (Encrypt & Write) ──

  /// Bundle all Isar collections, encrypt with AES-256-GCM using a
  /// key derived from [masterPin], and save to the sync directory.
  ///
  /// Returns `true` on success, `false` if no sync directory is set.
  Future<bool> exportVault(String masterPin) async {
    final syncDir = await getSyncDirectory();
    if (syncDir == null) return false;

    final db = DatabaseService.instance.db;

    // ── 1. Serialize all collections to JSON ──
    final payload = await _serializeDatabase(db);
    final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

    // ── 2. Derive encryption key from PIN ──
    final salt = _generateSecureRandom(_saltLength);
    final key = _deriveKey(masterPin, salt);

    // ── 3. Encrypt with AES-256-GCM ──
    final iv = enc.IV.fromSecureRandom(12); // 96-bit IV for GCM
    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(jsonBytes, iv: iv);

    // ── 4. Build the vault bundle: version + salt + iv + ciphertext ──
    final bundle = _buildBundle(salt, iv.bytes, encrypted.bytes);

    // ── 5. Write to sync directory ──
    final file = File('$syncDir${Platform.pathSeparator}$_syncFileName');
    await file.writeAsBytes(bundle);

    // ── 6. Zero-fill sensitive material ──
    _zeroFill(key);
    _zeroFill(jsonBytes);

    return true;
  }

  // ── Import (Read, Decrypt & Merge) ──

  /// Read `vault_state.forgevault` from the sync directory, verify the
  /// AES-256-GCM authentication tag, decrypt, and merge into Isar.
  ///
  /// Merge strategy: per-record, newest `lastUpdated` wins.
  /// Returns `true` on success, throws on authentication failure.
  Future<bool> importVault(String masterPin) async {
    final syncDir = await getSyncDirectory();
    if (syncDir == null) return false;

    final file = File('$syncDir${Platform.pathSeparator}$_syncFileName');
    if (!await file.exists()) return false;

    final bundle = await file.readAsBytes();

    // ── 1. Parse bundle ──
    final parsed = _parseBundle(Uint8List.fromList(bundle));
    if (parsed == null) {
      throw StateError('Invalid vault bundle format.');
    }

    // ── 2. Derive key from PIN ──
    final key = _deriveKey(masterPin, parsed.salt);

    // ── 3. Decrypt ──
    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
    );

    Uint8List plainBytes;
    try {
      plainBytes = Uint8List.fromList(
        encrypter.decryptBytes(
          enc.Encrypted(parsed.ciphertext),
          iv: enc.IV(parsed.iv),
        ),
      );
    } catch (e) {
      _zeroFill(key);
      throw StateError(
        'Decryption failed — wrong PIN or corrupted vault file.',
      );
    }

    _zeroFill(key);

    // ── 4. Deserialize JSON ──
    final jsonString = utf8.decode(plainBytes);
    _zeroFill(plainBytes);

    final Map<String, dynamic> payload =
        jsonDecode(jsonString) as Map<String, dynamic>;

    // ── 5. Merge into local Isar ──
    await _mergeIntoDatabase(DatabaseService.instance.db, payload);

    return true;
  }

  // ── Capsule Export (Share Sheet) ──

  /// Bundle the entire vault + PBKDF2 salt into a portable `.forgevault`
  /// capsule and open the OS Share Sheet.
  ///
  /// The capsule is a JSON file:
  /// ```json
  /// {"version": 1, "salt": "<base64>", "bundle": "<base64>"}
  /// ```
  /// where `bundle` is the AES-256-GCM encrypted database serialization
  /// and `salt` is the PBKDF2 salt required to re-derive the key on
  /// another device.
  Future<void> exportCapsule(String masterPin) async {
    final db = DatabaseService.instance.db;
    final keyService = KeyDerivationService();

    // 1. Serialize all collections
    final payload = await _serializeDatabase(db);
    final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

    // 2. Derive key from PIN (using local salt)
    final encSalt = _generateSecureRandom(_saltLength);
    final key = _deriveKey(masterPin, encSalt);

    // 3. Encrypt with AES-256-GCM
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(jsonBytes, iv: iv);

    // 4. Build binary bundle (version + encSalt + iv + ciphertext)
    final bundle = _buildBundle(encSalt, iv.bytes, encrypted.bytes);

    // 5. Read the PBKDF2 salt from disk (needed for cross-device restore)
    final pbkdf2Salt = await keyService.getSalt();

    // 6. Build the capsule JSON
    final capsule = jsonEncode({
      'version': _syncVersion,
      'salt': base64Encode(pbkdf2Salt),
      'bundle': base64Encode(bundle),
    });

    // 7. Save or share based on platform
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop: use native save dialog
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Encrypted Vault',
        fileName: 'ForgeVault_Backup.forgevault',
      );
      if (outputFile != null) {
        await File(outputFile).writeAsString(capsule);
      }
    } else {
      // Mobile: write to temp dir and trigger Share Sheet
      final tempDir = await getTemporaryDirectory();
      final capsulePath =
          '${tempDir.path}${Platform.pathSeparator}ForgeVault_Backup.forgevault';
      final file = File(capsulePath);
      await file.writeAsString(capsule);

      await Share.shareXFiles([
        XFile(capsulePath),
      ], subject: 'ForgeVault Encrypted Backup');
    }

    // 9. Zero-fill sensitive material
    _zeroFill(key);
    _zeroFill(jsonBytes);
  }

  // ── Capsule Import (Cold-Start Restore) ──

  /// Import a `.forgevault` capsule from [filePath], decrypting with [pin].
  ///
  /// This overwrites the local PBKDF2 salt and PIN verification hash
  /// so the restored device uses the same crypto material.
  Future<void> importCapsule(String filePath, String pin) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Capsule file not found.');
    }

    final raw = await file.readAsString();
    final Map<String, dynamic> capsule =
        jsonDecode(raw) as Map<String, dynamic>;

    // 1. Extract PBKDF2 salt and encrypted bundle
    final pbkdf2Salt = base64Decode(capsule['salt'] as String);
    final bundle = Uint8List.fromList(
      base64Decode(capsule['bundle'] as String),
    );

    // 2. Parse the binary bundle
    final parsed = _parseBundle(bundle);
    if (parsed == null) {
      throw StateError('Invalid capsule bundle format.');
    }

    // 3. Derive key from entered PIN + the capsule's encryption salt
    final key = _deriveKey(pin, parsed.salt);

    // 4. Decrypt
    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
    );

    Uint8List plainBytes;
    try {
      plainBytes = Uint8List.fromList(
        encrypter.decryptBytes(
          enc.Encrypted(parsed.ciphertext),
          iv: enc.IV(parsed.iv),
        ),
      );
    } catch (e) {
      _zeroFill(key);
      throw StateError('Invalid PIN or corrupted vault file.');
    }

    _zeroFill(key);

    final jsonString = utf8.decode(plainBytes);
    _zeroFill(plainBytes);

    final Map<String, dynamic> payload =
        jsonDecode(jsonString) as Map<String, dynamic>;

    // 5. Overwrite local crypto material with the capsule's
    final keyService = KeyDerivationService();
    await keyService.overwriteSalt(Uint8List.fromList(pbkdf2Salt));
    await keyService.storeVerificationHash(pin);

    // 5. Close existing Isar to release Windows file lock before re-init
    final existingIsar = Isar.getInstance();
    if (existingIsar != null && existingIsar.isOpen) {
      await existingIsar.close();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 5b. Delete stale sealed vault (.aes) so initialize() starts fresh
    try {
      final dir = await getApplicationSupportDirectory();
      final aesFile = File(
        '${dir.path}${Platform.pathSeparator}vitavault.isar.aes',
      );
      if (aesFile.existsSync()) aesFile.deleteSync();
    } catch (_) {}

    // 6. Initialize the database with the new crypto material
    await DatabaseService.instance.initialize(pin);

    // 7. Merge into local Isar
    await _mergeIntoDatabase(DatabaseService.instance.db, payload);
  }

  // ── Serialization ──

  Future<Map<String, dynamic>> _serializeDatabase(Isar db) async {
    return {
      'version': _syncVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'coreIdentities': await db.coreIdentitys.where().findAll().then(
        (list) => list.map(_coreIdentityToJson).toList(),
      ),
      'timelineEvents': await db.timelineEvents.where().findAll().then(
        (list) => list.map(_timelineEventToJson).toList(),
      ),
      'troubles': await db.troubles.where().findAll().then(
        (list) => list.map(_troubleToJson).toList(),
      ),
      'financeRecords': await db.financeRecords.where().findAll().then(
        (list) => list.map(_financeRecordToJson).toList(),
      ),
      'relationshipNodes': await db.relationshipNodes.where().findAll().then(
        (list) => list.map(_relationshipNodeToJson).toList(),
      ),
      'auditLogs': await db.auditLogs.where().findAll().then(
        (list) => list.map(_auditLogToJson).toList(),
      ),
      'healthProfiles': await db.healthProfiles.where().findAll().then(
        (list) => list.map(_healthProfileToJson).toList(),
      ),
      'goals': await db.goals.where().findAll().then(
        (list) => list.map(_goalToJson).toList(),
      ),
      'habitVices': await db.habitVices.where().findAll().then(
        (list) => list.map(_habitViceToJson).toList(),
      ),
      'medicalLedgers': await db.medicalLedgers.where().findAll().then(
        (list) => list.map(_medicalLedgerToJson).toList(),
      ),
      'careerLedgers': await db.careerLedgers.where().findAll().then(
        (list) => list.map(_careerLedgerToJson).toList(),
      ),
      'assetLedgers': await db.assetLedgers.where().findAll().then(
        (list) => list.map(_assetLedgerToJson).toList(),
      ),
      'relationalWebs': await db.relationalWebs.where().findAll().then(
        (list) => list.map(_relationalWebToJson).toList(),
      ),
      'psycheProfiles': await db.psycheProfiles.where().findAll().then(
        (list) => list.map(_psycheProfileToJson).toList(),
      ),
    };
  }

  // ── Merge Logic (newest wins) ──

  Future<void> _mergeIntoDatabase(Isar db, Map<String, dynamic> payload) async {
    await db.writeTxn(() async {
      // Core Identities — merge by id, newest lastUpdated wins
      final incomingIdentities =
          (payload['coreIdentities'] as List<dynamic>?) ?? [];
      for (final json in incomingIdentities) {
        final incoming = _coreIdentityFromJson(json as Map<String, dynamic>);
        final existing = await db.coreIdentitys.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.coreIdentitys.put(incoming);
        }
      }

      // Timeline Events — merge by id, newest eventDate wins
      final incomingEvents =
          (payload['timelineEvents'] as List<dynamic>?) ?? [];
      for (final json in incomingEvents) {
        final incoming = _timelineEventFromJson(json as Map<String, dynamic>);
        final existing = await db.timelineEvents.get(incoming.id);
        if (existing == null ||
            incoming.eventDate.isAfter(existing.eventDate)) {
          await db.timelineEvents.put(incoming);
        }
      }

      // Troubles — merge by id, newest dateIdentified wins
      final incomingTroubles = (payload['troubles'] as List<dynamic>?) ?? [];
      for (final json in incomingTroubles) {
        final incoming = _troubleFromJson(json as Map<String, dynamic>);
        final existing = await db.troubles.get(incoming.id);
        if (existing == null ||
            incoming.dateIdentified.isAfter(existing.dateIdentified)) {
          await db.troubles.put(incoming);
        }
      }

      // Finance Records — merge by id, newest lastUpdated wins
      final incomingFinance =
          (payload['financeRecords'] as List<dynamic>?) ?? [];
      for (final json in incomingFinance) {
        final incoming = _financeRecordFromJson(json as Map<String, dynamic>);
        final existing = await db.financeRecords.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.financeRecords.put(incoming);
        }
      }

      // Relationship Nodes — merge by id
      final incomingRelationships =
          (payload['relationshipNodes'] as List<dynamic>?) ?? [];
      for (final json in incomingRelationships) {
        final incoming = _relationshipNodeFromJson(
          json as Map<String, dynamic>,
        );
        final existing = await db.relationshipNodes.get(incoming.id);
        if (existing == null) {
          await db.relationshipNodes.put(incoming);
        }
      }

      // Audit Logs — always insert (append-only)
      final incomingLogs = (payload['auditLogs'] as List<dynamic>?) ?? [];
      for (final json in incomingLogs) {
        final incoming = _auditLogFromJson(json as Map<String, dynamic>);
        final existing = await db.auditLogs.get(incoming.id);
        if (existing == null) {
          await db.auditLogs.put(incoming);
        }
      }

      // Health Profiles — merge by id, newest lastUpdated wins
      final incomingHealth =
          (payload['healthProfiles'] as List<dynamic>?) ?? [];
      for (final json in incomingHealth) {
        final incoming = _healthProfileFromJson(json as Map<String, dynamic>);
        final existing = await db.healthProfiles.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.healthProfiles.put(incoming);
        }
      }

      // Goals — merge by id, newest dateCreated wins
      final incomingGoals = (payload['goals'] as List<dynamic>?) ?? [];
      for (final json in incomingGoals) {
        final incoming = _goalFromJson(json as Map<String, dynamic>);
        final existing = await db.goals.get(incoming.id);
        if (existing == null ||
            incoming.dateCreated.isAfter(existing.dateCreated)) {
          await db.goals.put(incoming);
        }
      }

      // Habit/Vices — merge by id
      final incomingHabits = (payload['habitVices'] as List<dynamic>?) ?? [];
      for (final json in incomingHabits) {
        final incoming = _habitViceFromJson(json as Map<String, dynamic>);
        final existing = await db.habitVices.get(incoming.id);
        if (existing == null) {
          await db.habitVices.put(incoming);
        }
      }

      // Medical Ledgers — merge by id, newest lastUpdated wins
      final incomingMedical =
          (payload['medicalLedgers'] as List<dynamic>?) ?? [];
      for (final json in incomingMedical) {
        final incoming = _medicalLedgerFromJson(json as Map<String, dynamic>);
        final existing = await db.medicalLedgers.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.medicalLedgers.put(incoming);
        }
      }

      // Career Ledgers — merge by id, newest lastUpdated wins
      final incomingCareer = (payload['careerLedgers'] as List<dynamic>?) ?? [];
      for (final json in incomingCareer) {
        final incoming = _careerLedgerFromJson(json as Map<String, dynamic>);
        final existing = await db.careerLedgers.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.careerLedgers.put(incoming);
        }
      }

      // Asset Ledgers — merge by id, newest lastUpdated wins
      final incomingAssets = (payload['assetLedgers'] as List<dynamic>?) ?? [];
      for (final json in incomingAssets) {
        final incoming = _assetLedgerFromJson(json as Map<String, dynamic>);
        final existing = await db.assetLedgers.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.assetLedgers.put(incoming);
        }
      }

      // Relational Webs — merge by id, newest lastUpdated wins
      final incomingRelWebs =
          (payload['relationalWebs'] as List<dynamic>?) ?? [];
      for (final json in incomingRelWebs) {
        final incoming = _relationalWebFromJson(json as Map<String, dynamic>);
        final existing = await db.relationalWebs.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.relationalWebs.put(incoming);
        }
      }

      // Psyche Profiles — merge by id, newest lastUpdated wins
      final incomingPsyche =
          (payload['psycheProfiles'] as List<dynamic>?) ?? [];
      for (final json in incomingPsyche) {
        final incoming = _psycheProfileFromJson(json as Map<String, dynamic>);
        final existing = await db.psycheProfiles.get(incoming.id);
        if (existing == null ||
            incoming.lastUpdated.isAfter(existing.lastUpdated)) {
          await db.psycheProfiles.put(incoming);
        }
      }
    });
  }

  // ── Crypto Helpers ──

  Uint8List _deriveKey(String pin, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(params);

    final pinBytes = Uint8List.fromList(utf8.encode(pin));
    final key = derivator.process(pinBytes);
    _zeroFill(pinBytes);

    return key;
  }

  Uint8List _generateSecureRandom(int length) {
    final rng = FortunaRandom()
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List<int>.generate(32, (_) => Random.secure().nextInt(256)),
          ),
        ),
      );
    return rng.nextBytes(length);
  }

  /// Bundle format: [1 byte version][16 bytes salt][12 bytes IV][N bytes cipher]
  Uint8List _buildBundle(Uint8List salt, Uint8List iv, Uint8List ciphertext) {
    final builder = BytesBuilder();
    builder.addByte(_syncVersion); // version byte
    builder.add(salt); // 16 bytes
    builder.add(iv); // 12 bytes
    builder.add(ciphertext); // remainder
    return builder.toBytes();
  }

  _ParsedBundle? _parseBundle(Uint8List data) {
    // Minimum: 1 (version) + 16 (salt) + 12 (iv) + 1 (cipher) = 30 bytes
    if (data.length < 30) return null;

    final version = data[0];
    if (version != _syncVersion) return null;

    final salt = Uint8List.fromList(data.sublist(1, 17));
    final iv = Uint8List.fromList(data.sublist(17, 29));
    final ciphertext = Uint8List.fromList(data.sublist(29));

    return _ParsedBundle(salt: salt, iv: iv, ciphertext: ciphertext);
  }

  void _zeroFill(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  // ── JSON Serialization Helpers ──

  Map<String, dynamic> _coreIdentityToJson(CoreIdentity ci) => {
    'id': ci.id,
    'fullName': ci.fullName,
    'dateOfBirth': ci.dateOfBirth?.toIso8601String(),
    'location': ci.location,
    'immutableTraits': ci.immutableTraits,
    'digitalFootprint': ci.digitalFootprint,
    'jobHistory': ci.jobHistory,
    'locationHistory': ci.locationHistory,
    'educationHistory': ci.educationHistory,
    'familyLineage': ci.familyLineage,
    'lastUpdated': ci.lastUpdated.toIso8601String(),
    'completenessScore': ci.completenessScore,
  };

  CoreIdentity _coreIdentityFromJson(Map<String, dynamic> j) {
    return CoreIdentity()
      ..id = j['id'] as int
      ..fullName = j['fullName'] as String
      ..dateOfBirth = j['dateOfBirth'] != null
          ? DateTime.parse(j['dateOfBirth'] as String)
          : null
      ..location = j['location'] as String
      ..immutableTraits = (j['immutableTraits'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..digitalFootprint = (j['digitalFootprint'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..jobHistory = (j['jobHistory'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..locationHistory = (j['locationHistory'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..educationHistory = (j['educationHistory'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..familyLineage = (j['familyLineage'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String)
      ..completenessScore = j['completenessScore'] as int;
  }

  Map<String, dynamic> _timelineEventToJson(TimelineEvent te) => {
    'id': te.id,
    'eventDate': te.eventDate.toIso8601String(),
    'title': te.title,
    'description': te.description,
    'category': te.category,
    'emotionalImpactScore': te.emotionalImpactScore,
    'isVerified': te.isVerified,
  };

  TimelineEvent _timelineEventFromJson(Map<String, dynamic> j) {
    return TimelineEvent()
      ..id = j['id'] as int
      ..eventDate = DateTime.parse(j['eventDate'] as String)
      ..title = j['title'] as String
      ..description = j['description'] as String
      ..category = j['category'] as String
      ..emotionalImpactScore = j['emotionalImpactScore'] as int
      ..isVerified = j['isVerified'] as bool;
  }

  Map<String, dynamic> _troubleToJson(Trouble t) => {
    'id': t.id,
    'title': t.title,
    'detailText': t.detailText,
    'category': t.category,
    'severity': t.severity,
    'isResolved': t.isResolved,
    'dateIdentified': t.dateIdentified.toIso8601String(),
    'relatedEntities': t.relatedEntities,
  };

  Trouble _troubleFromJson(Map<String, dynamic> j) {
    return Trouble()
      ..id = j['id'] as int
      ..title = j['title'] as String
      ..detailText = j['detailText'] as String
      ..category = j['category'] as String
      ..severity = j['severity'] as int
      ..isResolved = j['isResolved'] as bool
      ..dateIdentified = DateTime.parse(j['dateIdentified'] as String)
      ..relatedEntities = (j['relatedEntities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();
  }

  Map<String, dynamic> _financeRecordToJson(FinanceRecord fr) => {
    'id': fr.id,
    'assetOrDebtName': fr.assetOrDebtName,
    'amount': fr.amount,
    'isDebt': fr.isDebt,
    'notes': fr.notes,
    'lastUpdated': fr.lastUpdated.toIso8601String(),
  };

  FinanceRecord _financeRecordFromJson(Map<String, dynamic> j) {
    return FinanceRecord()
      ..id = j['id'] as int
      ..assetOrDebtName = j['assetOrDebtName'] as String
      ..amount = (j['amount'] as num).toDouble()
      ..isDebt = j['isDebt'] as bool
      ..notes = j['notes'] as String?
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _relationshipNodeToJson(RelationshipNode rn) => {
    'id': rn.id,
    'personName': rn.personName,
    'relationType': rn.relationType,
    'trustLevel': rn.trustLevel,
    'recentConflictOrSupport': rn.recentConflictOrSupport,
  };

  RelationshipNode _relationshipNodeFromJson(Map<String, dynamic> j) {
    return RelationshipNode()
      ..id = j['id'] as int
      ..personName = j['personName'] as String
      ..relationType = j['relationType'] as String
      ..trustLevel = j['trustLevel'] as int
      ..recentConflictOrSupport = j['recentConflictOrSupport'] as String?;
  }

  Map<String, dynamic> _auditLogToJson(AuditLog al) => {
    'id': al.id,
    'timestamp': al.timestamp.toIso8601String(),
    'action': al.action,
    'fileHashDestroyed': al.fileHashDestroyed,
  };

  AuditLog _auditLogFromJson(Map<String, dynamic> j) {
    return AuditLog()
      ..id = j['id'] as int
      ..timestamp = DateTime.parse(j['timestamp'] as String)
      ..action = j['action'] as String
      ..fileHashDestroyed = j['fileHashDestroyed'] as String;
  }

  Map<String, dynamic> _healthProfileToJson(HealthProfile hp) => {
    'id': hp.id,
    'conditions': hp.conditions,
    'medications': hp.medications,
    'allergies': hp.allergies,
    'bloodType': hp.bloodType,
    'primaryPhysician': hp.primaryPhysician,
    'insuranceInfo': hp.insuranceInfo,
    'lastUpdated': hp.lastUpdated.toIso8601String(),
  };

  HealthProfile _healthProfileFromJson(Map<String, dynamic> j) {
    return HealthProfile()
      ..id = j['id'] as int
      ..conditions = (j['conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..medications = (j['medications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..allergies = (j['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..bloodType = j['bloodType'] as String?
      ..primaryPhysician = j['primaryPhysician'] as String?
      ..insuranceInfo = j['insuranceInfo'] as String?
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _goalToJson(Goal g) => {
    'id': g.id,
    'title': g.title,
    'category': g.category,
    'description': g.description,
    'targetDate': g.targetDate?.toIso8601String(),
    'progress': g.progress,
    'isCompleted': g.isCompleted,
    'dateCreated': g.dateCreated.toIso8601String(),
  };

  Goal _goalFromJson(Map<String, dynamic> j) {
    return Goal()
      ..id = j['id'] as int
      ..title = j['title'] as String
      ..category = j['category'] as String
      ..description = j['description'] as String?
      ..targetDate = j['targetDate'] != null
          ? DateTime.parse(j['targetDate'] as String)
          : null
      ..progress = j['progress'] as int
      ..isCompleted = j['isCompleted'] as bool
      ..dateCreated = DateTime.parse(j['dateCreated'] as String);
  }

  Map<String, dynamic> _habitViceToJson(HabitVice hv) => {
    'id': hv.id,
    'name': hv.name,
    'isVice': hv.isVice,
    'frequency': hv.frequency,
    'severity': hv.severity,
    'notes': hv.notes,
    'dateIdentified': hv.dateIdentified.toIso8601String(),
  };

  HabitVice _habitViceFromJson(Map<String, dynamic> j) {
    return HabitVice()
      ..id = j['id'] as int
      ..name = j['name'] as String
      ..isVice = j['isVice'] as bool
      ..frequency = j['frequency'] as String
      ..severity = j['severity'] as int
      ..notes = j['notes'] as String?
      ..dateIdentified = DateTime.parse(j['dateIdentified'] as String);
  }

  // ── New Ledger Serialization Helpers ──

  static List<String> _parseStringListSync(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  Map<String, dynamic> _medicalLedgerToJson(MedicalLedger m) => {
    'id': m.id,
    'surgeries': m.surgeries,
    'genetics': m.genetics,
    'vitalBaselines': m.vitalBaselines,
    'visionRx': m.visionRx,
    'familyMedicalHistory': m.familyMedicalHistory,
    'bloodwork': m.bloodwork,
    'immunizations': m.immunizations,
    'dentalHistory': m.dentalHistory,
    'lastUpdated': m.lastUpdated.toIso8601String(),
  };

  MedicalLedger _medicalLedgerFromJson(Map<String, dynamic> j) {
    return MedicalLedger()
      ..id = j['id'] as int
      ..surgeries = _parseStringListSync(j['surgeries'])
      ..genetics = _parseStringListSync(j['genetics'])
      ..vitalBaselines = _parseStringListSync(j['vitalBaselines'])
      ..visionRx = _parseStringListSync(j['visionRx'])
      ..familyMedicalHistory = _parseStringListSync(j['familyMedicalHistory'])
      ..bloodwork = _parseStringListSync(j['bloodwork'])
      ..immunizations = _parseStringListSync(j['immunizations'])
      ..dentalHistory = _parseStringListSync(j['dentalHistory'])
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _careerLedgerToJson(CareerLedger c) => {
    'id': c.id,
    'jobs': c.jobs,
    'degrees': c.degrees,
    'certifications': c.certifications,
    'clearances': c.clearances,
    'skills': c.skills,
    'projects': c.projects,
    'lastUpdated': c.lastUpdated.toIso8601String(),
  };

  CareerLedger _careerLedgerFromJson(Map<String, dynamic> j) {
    return CareerLedger()
      ..id = j['id'] as int
      ..jobs = _parseStringListSync(j['jobs'])
      ..degrees = _parseStringListSync(j['degrees'])
      ..certifications = _parseStringListSync(j['certifications'])
      ..clearances = _parseStringListSync(j['clearances'])
      ..skills = _parseStringListSync(j['skills'])
      ..projects = _parseStringListSync(j['projects'])
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _assetLedgerToJson(AssetLedger a) => {
    'id': a.id,
    'realEstate': a.realEstate,
    'vehicles': a.vehicles,
    'digitalAssets': a.digitalAssets,
    'insurance': a.insurance,
    'investments': a.investments,
    'valuables': a.valuables,
    'lastUpdated': a.lastUpdated.toIso8601String(),
  };

  AssetLedger _assetLedgerFromJson(Map<String, dynamic> j) {
    return AssetLedger()
      ..id = j['id'] as int
      ..realEstate = _parseStringListSync(j['realEstate'])
      ..vehicles = _parseStringListSync(j['vehicles'])
      ..digitalAssets = _parseStringListSync(j['digitalAssets'])
      ..insurance = _parseStringListSync(j['insurance'])
      ..investments = _parseStringListSync(j['investments'])
      ..valuables = _parseStringListSync(j['valuables'])
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _relationalWebToJson(RelationalWeb rw) => {
    'id': rw.id,
    'family': rw.family,
    'mentors': rw.mentors,
    'adversaries': rw.adversaries,
    'colleagues': rw.colleagues,
    'friends': rw.friends,
    'lastUpdated': rw.lastUpdated.toIso8601String(),
  };

  RelationalWeb _relationalWebFromJson(Map<String, dynamic> j) {
    return RelationalWeb()
      ..id = j['id'] as int
      ..family = _parseStringListSync(j['family'])
      ..mentors = _parseStringListSync(j['mentors'])
      ..adversaries = _parseStringListSync(j['adversaries'])
      ..colleagues = _parseStringListSync(j['colleagues'])
      ..friends = _parseStringListSync(j['friends'])
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }

  Map<String, dynamic> _psycheProfileToJson(PsycheProfile p) => {
    'id': p.id,
    'beliefs': p.beliefs,
    'personality': p.personality,
    'fears': p.fears,
    'motivations': p.motivations,
    'enneagram': p.enneagram,
    'mbti': p.mbti,
    'strengths': p.strengths,
    'weaknesses': p.weaknesses,
    'lastUpdated': p.lastUpdated.toIso8601String(),
  };

  PsycheProfile _psycheProfileFromJson(Map<String, dynamic> j) {
    return PsycheProfile()
      ..id = j['id'] as int
      ..beliefs = _parseStringListSync(j['beliefs'])
      ..personality = _parseStringListSync(j['personality'])
      ..fears = _parseStringListSync(j['fears'])
      ..motivations = _parseStringListSync(j['motivations'])
      ..enneagram = j['enneagram'] as String?
      ..mbti = j['mbti'] as String?
      ..strengths = _parseStringListSync(j['strengths'])
      ..weaknesses = _parseStringListSync(j['weaknesses'])
      ..lastUpdated = DateTime.parse(j['lastUpdated'] as String);
  }
}

/// Internal helper for parsed vault bundle data.
class _ParsedBundle {
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List ciphertext;

  const _ParsedBundle({
    required this.salt,
    required this.iv,
    required this.ciphertext,
  });
}
