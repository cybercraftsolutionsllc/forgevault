import 'dart:io';

import 'package:flutter/services.dart';

/// Native MethodChannel bridge for OS-level operations.
///
/// Platform-specific implementations:
///   Android (Kotlin): FLAG_SECURE, file deletion via MediaStore
///   iOS (Swift): Screen capture prevention, file deletion
///   Windows (C++): File deletion with native dialog
///   macOS (Swift): File deletion via NSFileManager
///   Linux (C++): File deletion via gio
class VitaVaultNativeChannel {
  static const MethodChannel _channel = MethodChannel('com.vitavault/native');

  /// Trigger a native OS-level dialog to permanently delete a file.
  ///
  /// On Android: Uses MediaStore to move file to trash with user confirmation.
  /// On iOS: Uses UIDocumentInteractionController.
  /// On Desktop: Uses native file manager dialog.
  static Future<bool> deleteFileWithOsPrompt(String filePath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'deleteFileWithOsPrompt',
        {'path': filePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      // If native channel not implemented, fall back to Dart deletion.
      if (e.code == 'UNIMPLEMENTED') {
        return _fallbackDelete(filePath);
      }
      rethrow;
    } on MissingPluginException {
      // Native side not registered yet — graceful fallback.
      return _fallbackDelete(filePath);
    }
  }

  /// Disable OS-level screenshots and screen recording.
  ///
  /// Android: Sets FLAG_SECURE on the activity window.
  /// iOS: Prevents screen capture via UIScreen.
  /// Desktop: No-op (not applicable).
  static Future<void> disableScreenCapture() async {
    try {
      await _channel.invokeMethod('disableScreenCapture');
    } on PlatformException {
      // Not critical — silently fail on unsupported platforms.
    } on MissingPluginException {
      // Native side not registered — this is expected on desktop.
    }
  }

  /// Enable screen capture (for settings/debug).
  static Future<void> enableScreenCapture() async {
    try {
      await _channel.invokeMethod('enableScreenCapture');
    } on PlatformException {
      // Silently ignore.
    } on MissingPluginException {
      // Expected on desktop.
    }
  }

  /// Check if secure deletion is available on the current platform.
  static Future<bool> isSecureDeletionAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isSecureDeletionAvailable',
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Fallback ──

  static Future<bool> _fallbackDelete(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
