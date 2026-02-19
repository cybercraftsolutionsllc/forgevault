import '../native/method_channels.dart';

/// Screenshot & Screen Recording Prevention Service.
///
/// Thin orchestration layer over [ForgeVaultNativeChannel]:
///   - Android: Sets `WindowManager.LayoutParams.FLAG_SECURE`
///   - iOS: Implements UIScreen capture prevention
///   - Desktop: Graceful no-op (not applicable)
///
/// Called once at app startup to lock the display pipeline.
class SecurityFlagsService {
  SecurityFlagsService._();

  static bool _enabled = false;

  /// Whether screen capture prevention is currently active.
  static bool get isEnabled => _enabled;

  /// Enable all security flags. Called during app initialization.
  ///
  /// Sets FLAG_SECURE on Android and screen capture prevention on iOS.
  /// Silently no-ops on desktop platforms.
  static Future<void> enableAll() async {
    await ForgeVaultNativeChannel.disableScreenCapture();
    _enabled = true;
  }

  /// Disable all security flags. For debug/settings toggle.
  static Future<void> disableAll() async {
    await ForgeVaultNativeChannel.enableScreenCapture();
    _enabled = false;
  }

  /// Toggle security flags on/off.
  static Future<void> toggle() async {
    if (_enabled) {
      await disableAll();
    } else {
      await enableAll();
    }
  }
}
