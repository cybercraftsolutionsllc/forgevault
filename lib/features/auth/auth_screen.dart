import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../core/services/api_key_service.dart';
import '../../core/services/lifecycle_guard.dart';
import '../../theme/theme.dart';
import '../../core/database/database_service.dart';
import '../../providers/providers.dart';
import '../welcome/welcome_screen.dart';

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
        localizedReason: 'Unlock ForgeVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device credentials fallback
        ),
      );

      if (didAuthenticate && mounted) {
        // Read PIN from SecureStorage (saved when biometrics were enabled).
        const storage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        final storedPin = await storage.read(key: 'biometric_pin');
        if (storedPin != null && storedPin.isNotEmpty) {
          await DatabaseService.instance.initialize(storedPin);
          ref.read(masterPinProvider.notifier).state = storedPin;
          // Fire-and-forget: warm the API key cache.
          ApiKeyService().getActiveProvider();
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

        // Bump generation so stream providers resubscribe to fresh Isar
        ref.read(dbGenerationProvider.notifier).state++;

        // Store PIN in memory for biometric re-auth.
        ref.read(masterPinProvider.notifier).state = pin;

        // Fire-and-forget: warm the API key cache.
        ApiKeyService().getActiveProvider();
        widget.onAuthenticated();

        // Fallback self-navigation for post-nuke flow where
        // onAuthenticated is () {}. Navigate to main app.
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const LifecycleGuard(child: ForgeVaultApp()),
            ),
            (_) => false,
          );
        }
      } else {
        // Returning user — verify PIN
        final valid = await DatabaseService.instance.verifyPin(pin);
        if (valid) {
          await DatabaseService.instance.initialize(pin);

          // Bump generation so stream providers resubscribe to fresh Isar
          ref.read(dbGenerationProvider.notifier).state++;

          // Store PIN in memory for biometric re-auth.
          ref.read(masterPinProvider.notifier).state = pin;

          // Fire-and-forget: warm the API key cache.
          ApiKeyService().getActiveProvider();
          widget.onAuthenticated();

          // Fallback self-navigation
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LifecycleGuard(child: ForgeVaultApp()),
              ),
              (_) => false,
            );
          }
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
              'Setup error: $e',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            width: 400,
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
      bottomNavigationBar: !_isFirstTime
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: _showNukeDialog,
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: Text(
                    'Forgot PIN? (Reset Vault)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          : null,
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
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // ── Title ──
                Text(
                  'ForgeVault',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: VaultColors.textPrimary,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Forge your identity. Secure your sovereignty.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: VaultColors.textSecondary.withValues(alpha: 0.6),
                    letterSpacing: 0.3,
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
                            textInputAction: TextInputAction.done,
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

                const SizedBox(height: 40),

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

  // ── Factory Reset ──

  /// Permanently wipe ALL app state: Isar DB, secure storage, preferences.
  Future<void> _factoryReset() async {
    // 1. Scorched-earth Isar destruction (releases Windows file lock)
    try {
      await DatabaseService.instance.nukeDatabase();
    } catch (_) {}

    // 2. Flush ALL in-memory Riverpod state (kill memory zombies)
    ref.read(masterPinProvider.notifier).state = null;
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(isProUnlockedProvider.notifier).state = false;
    ref.read(syncDirectoryProvider.notifier).state = null;
    ref.read(vacuumStateProvider.notifier).state = VacuumState.idle;
    ref.invalidate(bioProgressProvider);
    // Bump generation counter so ALL stream providers resubscribe
    ref.read(dbGenerationProvider.notifier).state++;

    // 3. Wipe FlutterSecureStorage (salt, PIN hash, API keys, biometric_pin)
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.deleteAll();

    // 4. Wipe SharedPreferences (onboarding, biometrics, Pro flags)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 5. Wipe the salt and PIN verification files from app support dir
    try {
      final supportDir = await getApplicationSupportDirectory();
      final saltFile = File(
        '${supportDir.path}${Platform.pathSeparator}.vitavault_salt',
      );
      final verifyFile = File(
        '${supportDir.path}${Platform.pathSeparator}.vitavault_pin_verify',
      );
      if (saltFile.existsSync()) saltFile.deleteSync();
      if (verifyFile.existsSync()) verifyFile.deleteSync();
    } catch (_) {}
  }

  /// Show the NUKE confirmation dialog requiring the user to type 'NUKE'.
  Future<void> _showNukeDialog() async {
    final nukeController = TextEditingController();
    bool canNuke = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VaultColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: VaultColors.destructive.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          title: Text(
            '\u{1F6D1} WARNING: PERMANENT DATA LOSS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
              letterSpacing: 1,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'If you forgot your PIN, your data cannot be recovered. '
                'This will permanently wipe your local database and '
                'hardware-bound API keys. You will only be able to recover '
                'your data if you have an Encrypted Backup file.\n\n'
                'Type NUKE to confirm.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: VaultColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nukeController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  color: Colors.redAccent,
                  letterSpacing: 6,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: VaultColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: VaultColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: VaultColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  hintText: 'NUKE',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    color: VaultColors.textMuted,
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() => canNuke = value == 'NUKE');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: VaultColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: canNuke ? () => Navigator.of(context).pop(true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: VaultColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'NUKE VAULT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _factoryReset();
    } finally {
      // Flush ALL Riverpod state — forces re-read from fresh DB on next boot
      ref.invalidate(databaseProvider);
    }

    if (!mounted) return;

    // Navigate to WelcomeScreen, clearing the entire navigation stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            WelcomeScreen(onInitialize: () {}, onRestoreComplete: () {}),
      ),
      (_) => false,
    );
  }
}
