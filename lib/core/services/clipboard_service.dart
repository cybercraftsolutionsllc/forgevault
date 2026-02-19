import 'dart:async';

import 'package:flutter/services.dart';

/// Clipboard Timebomb — secure clipboard wrapper.
///
/// When data is copied from ForgeVault, the OS clipboard is
/// automatically cleared after [_clearDelaySeconds] seconds
/// to prevent cross-app clipboard snooping.
///
/// Usage:
/// ```dart
/// await ClipboardTimebomb.copy('sensitive text');
/// ```
class ClipboardTimebomb {
  static Timer? _clearTimer;
  static const int _clearDelaySeconds = 45;

  /// Copy [text] to the OS clipboard and schedule automatic
  /// clearing after 45 seconds.
  static Future<void> copy(String text) async {
    // Cancel any pending clear timer
    _clearTimer?.cancel();

    // Set clipboard data
    await Clipboard.setData(ClipboardData(text: text));

    // Schedule clipboard wipe
    _clearTimer = Timer(
      const Duration(seconds: _clearDelaySeconds),
      _clearClipboard,
    );
  }

  /// Immediately clear the clipboard (e.g., on app backgrounding).
  static Future<void> clearNow() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    await _clearClipboard();
  }

  /// Cancel any pending clipboard timer without clearing.
  static void cancelTimer() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }

  static Future<void> _clearClipboard() async {
    await Clipboard.setData(const ClipboardData(text: ''));
    _clearTimer = null;
  }
}
