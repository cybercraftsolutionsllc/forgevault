import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme.dart';
import '../../core/database/database_service.dart';
import '../../providers/providers.dart';

/// Biometric Gate — the first screen the user sees.
///
/// Pure black screen with a centered metallic vault icon.
/// Prompts for FaceID/TouchID/Windows Hello (if Pro unlocked),
/// then falls back to Master PIN entry.
class AuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  final LocalAuthentication _localAuth = LocalAuthentication();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isFirstTime = false;
  bool _isVerifying = false;
  bool _showPinInput = false;
  bool _pinError = false;
  bool _biometricsAvailable = false;
  bool _useBiometrics = false;
  String? _confirmPin; // For first-time PIN setup

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final configured = await DatabaseService.instance.isPinConfigured();
    setState(() => _isFirstTime = !configured);

    // Check biometric availability (only for returning users).
    if (configured) {
      await _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEnabled = prefs.getBool('useBiometrics') ?? false;
      _useBiometrics = userEnabled;

      if (!userEnabled) return; // User has NOT opted in — skip entirely.

      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;

      if (isSupported && canCheck) {
        setState(() => _biometricsAvailable = true);

        // Auto-trigger biometric auth only if user has opted in.
        _authenticateWithBiometrics();
      }
    } catch (_) {
      // Biometrics not available — silently fall back to PIN.
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() => _isVerifying = true);

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock VitaVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device credentials fallback
        ),
      );

      if (didAuthenticate && mounted) {
        // Use stored PIN to initialize database.
        final storedPin = ref.read(masterPinProvider);
        if (storedPin != null) {
          await DatabaseService.instance.initialize(storedPin);
          widget.onAuthenticated();
          return;
        }
        // If no stored PIN, fall back to manual PIN entry.
        setState(() {
          _biometricsAvailable = false;
          _isVerifying = false;
        });
      } else {
        setState(() => _isVerifying = false);
      }
    } on PlatformException {
      // Biometric auth failed — fall back to PIN.
      setState(() => _isVerifying = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _handlePinSubmit() async {
    final pin = _pinController.text;
    if (pin.length < 4) return;

    setState(() {
      _isVerifying = true;
      _pinError = false;
    });

    try {
      if (_isFirstTime) {
        if (_confirmPin == null) {
          // First entry — ask to confirm
          setState(() {
            _confirmPin = pin;
            _pinController.clear();
            _isVerifying = false;
          });
          return;
        }

        if (_confirmPin != pin) {
          // Confirmation failed
          setState(() {
            _confirmPin = null;
            _pinController.clear();
            _pinError = true;
            _isVerifying = false;
          });
          return;
        }

        // PINs match — set up and initialize
        await DatabaseService.instance.setupPin(pin);
        await DatabaseService.instance.initialize(pin);

        // Store PIN in memory for biometric re-auth.
        ref.read(masterPinProvider.notifier).state = pin;

        widget.onAuthenticated();
      } else {
        // Returning user — verify PIN
        final valid = await DatabaseService.instance.verifyPin(pin);
        if (valid) {
          await DatabaseService.instance.initialize(pin);

          // Store PIN in memory for biometric re-auth.
          ref.read(masterPinProvider.notifier).state = pin;

          widget.onAuthenticated();
        } else {
          setState(() {
            _pinError = true;
            _pinController.clear();
          });
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      setState(() => _pinError = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Vault Icon with Pulse ──
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            VaultColors.primaryLight.withValues(
                              alpha: _pulseAnimation.value * 0.3,
                            ),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: VaultColors.phosphorGreen.withValues(
                              alpha: _pulseAnimation.value * 0.1,
                            ),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2A2A2A),
                                Color(0xFF1A1A1A),
                                Color(0xFF0F0F0F),
                              ],
                            ),
                            border: Border.all(
                              color: VaultColors.border,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 36,
                            color: VaultColors.phosphorGreen,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // ── Title ──
                Text(
                  'VITAVAULT',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: VaultColors.textPrimary,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isFirstTime
                      ? 'Create your Master PIN to begin'
                      : 'Enter your Master PIN',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VaultColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),

                if (_confirmPin != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Confirm your PIN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: VaultColors.phosphorGreen,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // ── Biometric Button ──
                if (_biometricsAvailable && !_isFirstTime && !_showPinInput)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: _isVerifying ? null : _authenticateWithBiometrics,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: VaultColors.phosphorGreenDim,
                            width: 1,
                          ),
                          color: VaultColors.surface,
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 32,
                          color: VaultColors.phosphorGreen,
                        ),
                      ),
                    ),
                  ),

                // ── PIN Input ──
                if (!_showPinInput)
                  GestureDetector(
                    onTap: () => setState(() {
                      _showPinInput = true;
                      Future.delayed(
                        const Duration(milliseconds: 200),
                        () => _pinFocus.requestFocus(),
                      );
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: VaultColors.border,
                          width: 0.5,
                        ),
                        color: VaultColors.surface,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: VaultColors.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'TAP TO UNLOCK',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: VaultColors.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _pinController,
                            focusNode: _pinFocus,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 8,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 28,
                              color: VaultColors.phosphorGreen,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _pinError
                                      ? VaultColors.destructive
                                      : VaultColors.border,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _pinError
                                      ? VaultColors.destructive
                                      : VaultColors.border,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: VaultColors.phosphorGreenDim,
                                  width: 2,
                                ),
                              ),
                              filled: false,
                            ),
                            onSubmitted: (_) => _handlePinSubmit(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (_pinError)
                          Text(
                            _isFirstTime
                                ? 'PINs did not match. Try again.'
                                : 'Invalid PIN. Access denied.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: VaultColors.destructive,
                            ),
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: 200,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _handlePinSubmit,
                            child: _isVerifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: VaultColors.phosphorGreen,
                                    ),
                                  )
                                : Text(
                                    _isFirstTime
                                        ? (_confirmPin == null
                                              ? 'SET PIN'
                                              : 'CONFIRM')
                                        : 'UNLOCK',
                                    style: const TextStyle(letterSpacing: 2),
                                  ),
                          ),
                        ),

                        // ── Manual Biometric Trigger (on PIN pad) ──
                        if (_useBiometrics &&
                            _biometricsAvailable &&
                            !_isFirstTime)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: IconButton(
                              onPressed: _isVerifying
                                  ? null
                                  : _authenticateWithBiometrics,
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                size: 28,
                                color: VaultColors.phosphorGreen,
                              ),
                              tooltip: 'Unlock with biometrics',
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 64),

                // ── Version Tag ──
                Text(
                  'v1.0.0 • OFFLINE ONLY',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VaultColors.textMuted.withValues(alpha: 0.5),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
