import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../config/environment_config.dart';
import '../crypto/ephemeral_key_service.dart';
import '../database/database_service.dart';
import '../database/schemas/audit_log.dart';
import '../native/method_channels.dart';

/// The Purge — cryptographic erasure and cleanup.
///
/// 1. Destroys the ephemeral AES-256 key (zero-fill from RAM).
/// 2. Deletes the encrypted sandbox file.
/// 3. Triggers native OS deletion of the original unencrypted file.
/// 4. Writes an immutable AuditLog entry.
///
/// After purge, the raw data is mathematically unrecoverable.
/// Zero SSD wear — no multi-pass overwrite needed.
///
/// **Blast Shield**: In safe mode ([isSafeMode] == true), all destructive
/// operations are bypassed. Files are moved to `vitavault_debug_trash/`
/// instead of being destroyed.
class PurgeService {
  final DatabaseService _database;

  PurgeService({required DatabaseService database}) : _database = database;

  /// Execute the full purge sequence.
  Future<void> purge({
    required String sandboxPath,
    required String fileHash,
    required EphemeralKeyService ephemeralCrypto,
    String? originalFilePath,
  }) async {
    if (isSafeMode) {
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // BLAST SHIELD ENGAGED — No real destruction occurs.
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      developer.log(
        '\x1B[31m[SAFE MODE] WOULD HAVE PURGED: $sandboxPath\x1B[0m',
        name: 'PurgeService',
      );
      developer.log(
        '\x1B[31m[SAFE MODE] Key destruction SKIPPED for hash: $fileHash\x1B[0m',
        name: 'PurgeService',
      );

      // Move sandbox file to debug trash instead of deleting
      await _moveToDebugTrash(sandboxPath);

      // Move original file too (if provided)
      if (originalFilePath != null) {
        developer.log(
          '\x1B[31m[SAFE MODE] WOULD HAVE PURGED ORIGINAL: $originalFilePath\x1B[0m',
          name: 'PurgeService',
        );
        await _moveToDebugTrash(originalFilePath);
      }

      // Still write the audit log (for test assertions)
      await _writeAuditLog('PURGE_SAFE_MODE', fileHash);
      return;
    }

    // ── Production Path ──

    // Step 1: Destroy the ephemeral key from RAM
    ephemeralCrypto.destroy();

    // Step 2: Delete the encrypted sandbox file
    await _deleteSandboxFile(sandboxPath);

    // Step 3: If original path provided, trigger OS deletion prompt
    if (originalFilePath != null) {
      await _deleteOriginalWithOsPrompt(originalFilePath);
    }

    // Step 4: Write immutable audit entry
    await _writeAuditLog('PURGE_COMPLETE', fileHash);
  }

  /// Delete just the sandbox file without full purge (e.g., on error).
  Future<void> cleanupSandbox(String sandboxPath) async {
    if (isSafeMode) {
      developer.log(
        '\x1B[31m[SAFE MODE] WOULD HAVE CLEANED UP: $sandboxPath\x1B[0m',
        name: 'PurgeService',
      );
      await _moveToDebugTrash(sandboxPath);
      return;
    }
    await _deleteSandboxFile(sandboxPath);
  }

  /// Get the debug trash directory path.
  static Future<Directory> getDebugTrashDir() async {
    final appDir = await getApplicationSupportDirectory();
    final trashDir = Directory(
      '${appDir.path}${Platform.pathSeparator}vitavault_debug_trash',
    );
    if (!await trashDir.exists()) {
      await trashDir.create(recursive: true);
    }
    return trashDir;
  }

  // ── Private Helpers ──

  Future<void> _moveToDebugTrash(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final trashDir = await getDebugTrashDir();
    final fileName = filePath.split(Platform.pathSeparator).last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final trashPath =
        '${trashDir.path}${Platform.pathSeparator}${timestamp}_$fileName';

    await file.rename(trashPath);
    developer.log(
      '\x1B[33m[SAFE MODE] Moved to debug trash: $trashPath\x1B[0m',
      name: 'PurgeService',
    );
  }

  Future<void> _deleteSandboxFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _deleteOriginalWithOsPrompt(String filePath) async {
    try {
      await VitaVaultNativeChannel.deleteFileWithOsPrompt(filePath);
    } catch (e) {
      // Fallback: attempt direct deletion if native channel fails.
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _writeAuditLog(String action, String fileHash) async {
    final db = _database.db;
    await db.writeTxn(() async {
      await db.auditLogs.put(
        AuditLog()
          ..timestamp = DateTime.now()
          ..action = action
          ..fileHashDestroyed = fileHash,
      );
    });
  }
}
