import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'clipboard_service.dart';

/// App-Level Panic Blur — covers the entire MaterialApp with a
/// high-opacity `BackdropFilter` when the app is backgrounded.
///
/// Behavior:
///   1. `inactive` / `paused` / `hidden` → instant blur overlay
///      + memory scrub of sensitive providers + clipboard clear
///   2. `resumed` within 60 seconds → remove blur, continue session
///   3. `resumed` after 60+ seconds → clear state, force re-auth
///
/// Wrap this around the authenticated content in [VitaVaultRoot].
class LifecycleGuard extends ConsumerStatefulWidget {
  final Widget child;

  /// Callback fired when the user must re-authenticate after a
  /// prolonged background period (>60 seconds).
  final VoidCallback onForceReauth;

  const LifecycleGuard({
    super.key,
    required this.child,
    required this.onForceReauth,
  });

  @override
  ConsumerState<LifecycleGuard> createState() => _LifecycleGuardState();
}

class _LifecycleGuardState extends ConsumerState<LifecycleGuard>
    with WidgetsBindingObserver {
  bool _isBlurred = false;
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
          // Overwrite active providers that may hold PII, extracted
          // text, or decrypted data to protect against RAM-dump attacks.
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
            // Exceeded 60s — invalidate state and force re-auth.
            ref.invalidate(vacuumStateProvider);
            ref.invalidate(isAuthenticatedProvider);
            _backgroundedAt = null;
            setState(() => _isBlurred = false);
            widget.onForceReauth();
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

  /// Overwrite sensitive Riverpod state providers with null/empty
  /// to prevent RAM dump recovery of PII.
  void _scrubSensitiveMemory() {
    // Invalidate providers that may hold extracted raw text,
    // decrypted data, or user-entered sensitive content.
    ref.invalidate(vacuumStateProvider);

    // Clear the master PIN from memory.
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
