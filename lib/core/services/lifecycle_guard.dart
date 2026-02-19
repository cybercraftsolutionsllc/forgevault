import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_screen.dart';
import '../../providers/providers.dart';
import 'clipboard_service.dart';

/// App-Level Panic Blur — covers the entire MaterialApp with a
/// high-opacity `BackdropFilter` when the app is backgrounded.
///
/// Behavior:
///   1. `inactive` / `paused` / `hidden` → instant blur overlay
///      + memory scrub of sensitive providers + clipboard clear
///   2. `resumed` within 60 seconds → remove blur, continue session
///   3. `resumed` after 60+ seconds → push AuthScreen as fullscreen
///      modal on top, preserving the current navigation stack
///
/// Wrap this around the authenticated content in [ForgeVaultRoot].
class LifecycleGuard extends ConsumerStatefulWidget {
  final Widget child;

  const LifecycleGuard({super.key, required this.child});

  @override
  ConsumerState<LifecycleGuard> createState() => _LifecycleGuardState();
}

class _LifecycleGuardState extends ConsumerState<LifecycleGuard>
    with WidgetsBindingObserver {
  bool _isBlurred = false;
  bool _isLockScreenShowing = false;
  DateTime? _backgroundedAt;

  static const Duration _reauthThreshold = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Instantly blur and record the timestamp.
        if (!_isBlurred) {
          _backgroundedAt = DateTime.now();
          setState(() => _isBlurred = true);

          // ── Memory Scrub: clear sensitive in-memory data ──
          _scrubSensitiveMemory();

          // ── Clipboard Wipe: prevent cross-app snooping ──
          ClipboardTimebomb.clearNow();
        }
        break;

      case AppLifecycleState.resumed:
        if (_isBlurred) {
          final elapsed = _backgroundedAt != null
              ? DateTime.now().difference(_backgroundedAt!)
              : Duration.zero;

          if (elapsed > _reauthThreshold) {
            // Exceeded 60s — push lock screen as fullscreen modal.
            // The underlying navigation stack is preserved.
            ref.invalidate(vacuumStateProvider);
            _backgroundedAt = null;
            setState(() => _isBlurred = false);
            _pushLockScreen();
          } else {
            // Under 60s — just remove the blur.
            _backgroundedAt = null;
            setState(() => _isBlurred = false);
          }
        }
        break;

      case AppLifecycleState.detached:
        // Final cleanup — scrub everything before process death.
        _scrubSensitiveMemory();
        break;
    }
  }

  /// Push AuthScreen as a fullscreen modal dialog on top of the
  /// current navigation stack. When the user successfully authenticates,
  /// Navigator.pop returns them exactly where they left off.
  void _pushLockScreen() {
    if (_isLockScreenShowing) return; // Prevent double-push
    _isLockScreenShowing = true;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PopScope(
          canPop: false, // Prevent back-button dismissal
          child: AuthScreen(
            onAuthenticated: () {
              _isLockScreenShowing = false;
              Navigator.of(context).pop(); // Return to previous screen
            },
          ),
        ),
      ),
    );
  }

  /// Overwrite sensitive Riverpod state providers with null/empty
  /// to prevent RAM dump recovery of PII.
  void _scrubSensitiveMemory() {
    ref.invalidate(vacuumStateProvider);
    ref.read(masterPinProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // ── Panic Blur Overlay ──
        if (_isBlurred)
          Positioned.fill(
            child: AbsorbPointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: const Center(
                    child: Icon(
                      Icons.security_rounded,
                      size: 64,
                      color: Color(0xFF1B4332), // Forest Green
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
