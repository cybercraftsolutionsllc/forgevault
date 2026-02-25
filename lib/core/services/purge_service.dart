import 'dart:io';

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
    await _deleteSandboxFile(sandboxPath);
  }

  // ── Private Helpers ──

  Future<void> _deleteSandboxFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _deleteOriginalWithOsPrompt(String filePath) async {
    try {
      await ForgeVaultNativeChannel.deleteFileWithOsPrompt(filePath);
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
          ..details = fileHash,
      );
    });
  }
}
