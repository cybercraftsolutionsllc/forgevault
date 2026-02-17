import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

/// App-Level Panic Blur — covers the entire MaterialApp with a
/// high-opacity `BackdropFilter` when the app is backgrounded.
///
/// Behavior:
///   1. `inactive` / `paused` / `hidden` → instant blur overlay
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
        break;
    }
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
