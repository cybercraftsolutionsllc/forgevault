import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_service.dart';
import 'cipher_service.dart';
import 'revenuecat_service.dart';
import 'vault_sync_service.dart';

/// E2EE Archiver — Asynchronous, password-based encrypted vault sync.
///
/// Uses [CipherService] (AES-256-GCM + SHA-256 key) to produce portable
/// `.forge` artifacts that can be transferred via any medium (email,
/// cloud drive, USB) without compromising Zero-Trust architecture.
///
/// The master payload includes device state (Master PIN hash + PRO status)
/// so the restore target automatically inherits the exporting vault's
/// authentication and subscription state.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final _cipher = CipherService.instance;
  final _syncService = VaultSyncService();

  static const _proKey = 'forgevault_pro_unlocked';

  /// Export the entire vault as an E2EE `.forge` file.
  ///
  /// The encrypted payload is a master JSON envelope:
  /// ```json
  /// { "metadata": { "masterPin": "...", "isPro": true },
  ///   "vaultData": "...serialized Isar JSON..." }
  /// ```
  ///
  /// 1. Serialize all Isar collections (via VaultSyncService)
  /// 2. Fetch Master PIN + isPro status
  /// 3. Wrap into master payload envelope
  /// 4. Encrypt with AES-256-GCM using SHA-256(password)
  /// 5. Let user save as `my_vault.forge`
  /// 6. Log an AuditRecord for the export
  Future<void> exportEncryptedVault(
    String password, {
    String? masterPin,
  }) async {
    final db = DatabaseService.instance;

    // 1. Serialize Isar collections
    final payload = await _syncService.serializeForExport();
    final vaultDataJson = jsonEncode(payload);

    // 2. Fetch device state — read live PRO status from the reactive notifier,
    //    NOT SharedPreferences, which may be stale.
    final isProActive = RevenueCatService().isProNotifier.value;
    debugPrint('[Export] isPro (live notifier): $isProActive');

    // 3. Build master payload envelope
    final masterPayload = jsonEncode({
      'metadata': {'masterPin': masterPin, 'isPro': isProActive},
      'vaultData': vaultDataJson,
    });

    // 4. Encrypt
    final encrypted = _cipher.encryptVault(masterPayload, password);
    final encryptedBytes = utf8.encode(encrypted);
    debugPrint('[Export] Encrypted payload: ${encryptedBytes.length} bytes');

    // 5. Save via FilePicker (all platforms)
    try {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Encrypted Vault',
        fileName: 'vault.forge',
        bytes: Uint8List.fromList(encryptedBytes),
      );
      if (outputFile == null) {
        debugPrint('[Export] User cancelled save dialog');
        return;
      }
      // On some platforms, FilePicker returns a path but may not write bytes.
      // Ensure the file exists; if not, write manually.
      final safePath = outputFile.toLowerCase().endsWith('.forge')
          ? outputFile
          : '$outputFile.forge';
      final outFile = File(safePath);
      if (!await outFile.exists() || await outFile.length() == 0) {
        await outFile.writeAsBytes(encryptedBytes);
      }
      debugPrint('[Export] File saved: $safePath');
    } catch (e, stackTrace) {
      debugPrint('[Export] Save failed: $e');
      debugPrint('[Export] Stack trace: $stackTrace');
      rethrow;
    }

    // 6. Audit log
    await db.addAuditLog(
      'Encrypted Vault Exported',
      'AES-256-GCM encrypted vault exported as .forge artifact.',
    );
  }

  /// Import and decrypt a `.forge` file, replacing the local vault.
  ///
  /// Uses `withData: true` to load bytes into RAM (bypasses Android
  /// content:// URI corruption).
  ///
  /// Throws [StateError] if the password is wrong or data is corrupt.
  Future<void> importEncryptedVault(String password) async {
    // 1. Pick file with bytes in RAM
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Select .forge File',
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    // Validate extension manually
    if (!file.name.endsWith('.forge')) {
      throw StateError('Invalid file format. Only .forge files are supported.');
    }

    // 2. Aggressively extract bytes — RAM first, path fallback
    Uint8List? fileBytes = file.bytes;
    if (fileBytes == null && file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }
    if (fileBytes == null) {
      throw StateError(
        'OS denied access to file bytes. Try moving the file to local storage.',
      );
    }

    await importFromBytes(fileBytes, password);
  }

  /// Import and decrypt a `.forge` file from raw bytes (no FilePicker).
  ///
  /// Used when the caller has already picked the file and collected the
  /// password via a dialog.
  ///
  /// Supports both new master-payload envelopes and legacy flat payloads.
  Future<void> importFromBytes(Uint8List fileBytes, String password) async {
    final encrypted = utf8.decode(fileBytes, allowMalformed: true).trim();
    final jsonString = _cipher.decryptVault(encrypted, password);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    // Detect master-payload envelope vs legacy flat payload
    final vaultData = _extractVaultData(decoded);

    // Restore PRO status from metadata (if present)
    await _restoreProStatus(decoded);

    await _syncService.replaceFromPayload(vaultData);
    await DatabaseService.instance.addAuditLog(
      'Encrypted Backup Restored',
      'Vault restored from encrypted .forge artifact.',
    );
  }

  /// Decrypt and extract metadata + vaultData from raw bytes.
  ///
  /// Returns a map with 'metadata' and 'vaultData' keys.
  /// Used by the welcome screen to extract PIN/Pro before DB init.
  Map<String, dynamic> decryptAndExtract(Uint8List fileBytes, String password) {
    final encrypted = utf8.decode(fileBytes, allowMalformed: true).trim();
    final jsonString = _cipher.decryptVault(encrypted, password);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    // Extract metadata (fallback for legacy payloads)
    final metadata =
        (decoded['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final vaultData = _extractVaultData(decoded);

    return {'metadata': metadata, 'vaultData': vaultData};
  }

  /// Import pre-parsed vault data directly (no decryption needed).
  ///
  /// Used after [decryptAndExtract] when the welcome screen has already
  /// decrypted and verified the payload.
  Future<void> importParsedPayload(Map<String, dynamic> vaultData) async {
    await _syncService.replaceFromPayload(vaultData);
    await DatabaseService.instance.addAuditLog(
      'Encrypted Backup Restored',
      'Vault restored from encrypted .forge artifact.',
    );
  }

  /// Import and decrypt a `.forge` file from a known path (no FilePicker).
  ///
  /// Used on desktop where file paths are reliable.
  Future<void> importFromPath(String filePath, String password) async {
    final bytes = await File(filePath).readAsBytes();
    return importFromBytes(bytes, password);
  }

  /// Extract vault data from either a master-payload envelope or legacy
  /// flat payload. Provides backwards compatibility.
  Map<String, dynamic> _extractVaultData(Map<String, dynamic> decoded) {
    if (decoded.containsKey('vaultData') && decoded.containsKey('metadata')) {
      // New master-payload format — vaultData is a JSON string
      final vaultDataRaw = decoded['vaultData'];
      if (vaultDataRaw is String) {
        return jsonDecode(vaultDataRaw) as Map<String, dynamic>;
      }
      return vaultDataRaw as Map<String, dynamic>;
    }
    // Legacy flat payload — the entire decoded map IS the vault data
    return decoded;
  }

  /// Restore PRO status from the metadata envelope.
  Future<void> _restoreProStatus(Map<String, dynamic> decoded) async {
    final metadata = decoded['metadata'] as Map<String, dynamic>?;
    if (metadata == null) return;
    final isPro = metadata['isPro'] as bool? ?? false;
    if (isPro) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_proKey, true);
      await prefs.setBool('offline_license_active', true);
      RevenueCatService().isProNotifier.value = true;
    }
  }
}
