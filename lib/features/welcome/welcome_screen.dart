import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../core/database/database_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/lifecycle_guard.dart';
import '../../core/services/revenuecat_service.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';
import '../auth/auth_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// Welcome Screen â€” shown when no Master PIN / salt is configured.
///
/// Provides two entry points:
/// 1. **Initialize New Vault** â€” routes to the Onboarding flow.
/// 2. **Restore from Backup** â€” picks a `.forge` artifact, prompts
///    for the backup password, decrypts, and bootstraps the database.
class WelcomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onInitialize;
  final VoidCallback onRestoreComplete;

  const WelcomeScreen({
    super.key,
    required this.onInitialize,
    required this.onRestoreComplete,
  });

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  /// Handle Initialize tap â€” self-navigating to avoid dead callbacks.
  ///
  /// When pushed from the Nuke flow, `widget.onInitialize` is `() {}`.
  /// In that case, we self-navigate to the OnboardingScreen via Navigator.
  void _handleInitialize() {
    // Try the parent callback first (works from main.dart routing)
    widget.onInitialize();

    // Self-navigate as fallback â€” push OnboardingScreen directly.
    // OnboardingScreen will navigate to AuthScreen on completion.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onComplete: () {
              // After onboarding, navigate to AuthScreen for PIN creation
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => AuthScreen(onAuthenticated: () {}),
                ),
                (_) => false,
              );
            },
          ),
        ),
        (_) => false,
      );
    }
  }

  Future<void> _startRestore() async {
    // 1. Pick a .forge file (FileType.any for Android SAF compat)
    // withData: true loads bytes into RAM (avoids Android content:// crashes)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Select Backup File',
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final fileName = file.name;

    // Route based on extension
    if (!fileName.toLowerCase().endsWith('.forge')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid file format. Only .forge files are supported.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
      return;
    }

    Uint8List? fileBytes = file.bytes;
    if (fileBytes == null && file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }
    if (fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OS denied access to file bytes. Try moving the file to local storage.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
      return;
    }
    return _restoreFromForge(fileBytes);
  }

  /// Restore from E2EE .forge artifact (password-based)
  ///
  /// Verification sequence:
  /// 1. Prompt for transport/backup password
  /// 2. Decrypt + extract metadata (masterPin + isPro) and vaultData
  /// 3. Prompt user to verify the extracted Master PIN
  /// 4. setupPin + initialize (boots Isar)
  /// 5. Import vaultData into Isar
  /// 6. Save isPro + hasCompletedOnboarding
  /// 7. Route to main app
  Future<void> _restoreFromForge(Uint8List fileBytes) async {
    if (!mounted) return;

    // â”€â”€ Step 1: Transport password â”€â”€
    final password = await _showPasswordDialog();
    if (password == null || password.isEmpty) return;

    setState(() => _isRestoring = true);

    try {
      // â”€â”€ Step 2: Decrypt + extract envelope â”€â”€
      final syncService = SyncService.instance;
      final envelope = syncService.decryptAndExtract(fileBytes, password);
      final metadata = envelope['metadata'] as Map<String, dynamic>;
      final vaultData = envelope['vaultData'] as Map<String, dynamic>;

      // Extract device state (fallback for legacy backups)
      final extractedPin = metadata['masterPin'] as String?;
      final extractedIsPro = metadata['isPro'] as bool? ?? false;

      // â”€â”€ Step 3: Verify Vault â€” user must enter the Master PIN â”€â”€
      if (!mounted) return;
      final enteredPin = await _showVerifyPinDialog(extractedPin != null);
      if (enteredPin == null || enteredPin.isEmpty) {
        if (mounted) setState(() => _isRestoring = false);
        return;
      }

      // If we have an extracted PIN, verify it matches
      if (extractedPin != null && enteredPin != extractedPin) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: VaultColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'PIN Mismatch',
                style: GoogleFonts.inter(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'The PIN you entered does not match the vault\'s Master PIN. '
                'Please try again with the correct PIN.',
                style: GoogleFonts.inter(
                  color: VaultColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(color: VaultColors.phosphorGreen),
                  ),
                ),
              ],
            ),
          );
          setState(() => _isRestoring = false);
        }
        return;
      }

      // Use the entered PIN (for legacy backups without metadata,
      // the entered PIN becomes the new Master PIN)
      final pinToUse = extractedPin ?? enteredPin;

      // â”€â”€ Step 4: Boot the database â”€â”€
      await DatabaseService.instance.setupPin(pinToUse);
      await DatabaseService.instance.initialize(pinToUse);
      ref.read(dbGenerationProvider.notifier).state++;
      ref.read(masterPinProvider.notifier).state = pinToUse;

      // â”€â”€ Step 5: Import vaultData into Isar â”€â”€
      await SyncService.instance.importParsedPayload(vaultData);

      // â”€â”€ Step 6: Save device state â”€â”€
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setBool('forgevault_pro_unlocked', extractedIsPro);
      RevenueCatService().isProNotifier.value = extractedIsPro;

      _invalidateAllProviders();

      // â”€â”€ Step 7: Route to main app â”€â”€
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vault Restored from .forge Artifact',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LifecycleGuard(child: ForgeVaultApp()),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: VaultColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Restore Failed',
              style: GoogleFonts.inter(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              e.toString(),
              style: GoogleFonts.inter(
                color: VaultColors.textSecondary,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(color: VaultColors.phosphorGreen),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  /// Show "Verify Vault" dialog â€” user must enter the vault's Master PIN.
  Future<String?> _showVerifyPinDialog(bool hasExtractedPin) {
    final pinCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          hasExtractedPin ? 'Verify Vault Identity' : 'V1 Archive Detected',
          style: GoogleFonts.inter(
            color: VaultColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasExtractedPin
                  ? 'Enter the Master PIN associated with this encrypted backup to authorize this device.'
                  : 'This backup uses an older format. Please enter the Master PIN originally used to secure it.',
              style: GoogleFonts.inter(
                color: VaultColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.jetBrainsMono(
                color: VaultColors.textPrimary,
                fontSize: 18,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'Master PIN',
                hintStyle: GoogleFonts.inter(color: VaultColors.textMuted),
                filled: true,
                fillColor: VaultColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: VaultColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.phosphorGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final p = pinCtrl.text;
              if (p.length < 4) return;
              Navigator.pop(ctx, p);
            },
            child: Text(
              'Verify',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Flush all Riverpod stream providers so ghost data is purged.
  void _invalidateAllProviders() {
    ref.invalidate(databaseProvider);
    ref.invalidate(bioProgressProvider);
    ref.invalidate(identityStreamProvider);
    ref.invalidate(timelineStreamProvider);
    ref.invalidate(troublesStreamProvider);
    ref.invalidate(goalsStreamProvider);
    ref.invalidate(healthStreamProvider);
    ref.invalidate(financesStreamProvider);
    ref.invalidate(relationshipsStreamProvider);
    ref.invalidate(habitsStreamProvider);
    ref.invalidate(medicalLedgerStreamProvider);
    ref.invalidate(careerLedgerStreamProvider);
    ref.invalidate(assetLedgerStreamProvider);
    ref.invalidate(relationalWebStreamProvider);
    ref.invalidate(psycheProfileStreamProvider);
    ref.read(dbGenerationProvider.notifier).state++;
  }

  /// Show dialog to enter backup password for .forge decryption.
  Future<String?> _showPasswordDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Text(
          'ENTER BACKUP PASSWORD',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: VaultColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the password used when this .forge artifact was exported.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VaultColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.of(context).pop(controller.text),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: VaultColors.textPrimary,
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
                  borderSide: const BorderSide(
                    color: VaultColors.phosphorGreen,
                  ),
                ),
                hintText: 'Backup passwordâ€¦',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: VaultColors.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: VaultColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              foregroundColor: VaultColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'DECRYPT',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // â”€â”€ Animated Vault Icon â”€â”€
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          VaultColors.phosphorGreen.withValues(
                            alpha: _glowAnimation.value * 0.14,
                          ),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: VaultColors.phosphorGreen.withValues(
                            alpha: _glowAnimation.value * 0.08,
                          ),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // â”€â”€ Title â”€â”€
              Text(
                'ForgeVault',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: VaultColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Forge your identity. Secure your sovereignty.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: VaultColors.textSecondary.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              // â”€â”€ Initialize Button â”€â”€
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleInitialize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VaultColors.primary,
                    foregroundColor: VaultColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: VaultColors.phosphorGreenDim,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'INITIALIZE NEW VAULT',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // â”€â”€ Restore Button â”€â”€
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isRestoring ? null : _startRestore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VaultColors.textSecondary,
                    side: BorderSide(color: VaultColors.border, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isRestoring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VaultColors.phosphorGreen,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.restore_rounded,
                              size: 18,
                              color: VaultColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'RESTORE FROM BACKUP',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: VaultColors.textSecondary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
