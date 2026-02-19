import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/vault_sync_service.dart';
import '../../theme/theme.dart';

/// Welcome Screen — shown when no Master PIN / salt is configured.
///
/// Provides two entry points:
/// 1. **Initialize New Vault** — routes to the Onboarding flow.
/// 2. **Restore from Backup** — picks a `.forgevault` capsule, prompts
///    for the original vault PIN, decrypts, and bootstraps the database.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onInitialize;
  final VoidCallback onRestoreComplete;

  const WelcomeScreen({
    super.key,
    required this.onInitialize,
    required this.onRestoreComplete,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
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

  Future<void> _startRestore() async {
    // 1. Pick a .forgevault or legacy .vitavault file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['forgevault', 'vitavault'],
      dialogTitle: 'Select ForgeVault Backup',
    );

    if (result == null || result.files.single.path == null) return;
    final filePath = result.files.single.path!;

    if (!filePath.endsWith('.forgevault') && !filePath.endsWith('.vitavault')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a .forgevault or .vitavault file.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
      return;
    }

    // 2. Prompt for the original vault PIN
    if (!mounted) return;
    final pin = await _showPinDialog();
    if (pin == null || pin.isEmpty) return;

    // 3. Attempt capsule import
    setState(() => _isRestoring = true);

    try {
      await VaultSyncService().importCapsule(filePath, pin);

      // Hydrate setup state so the app routes to Auth on next launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vault Restored Successfully',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
        widget.onRestoreComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid PIN or Corrupted Vault',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<String?> _showPinDialog() {
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
          'ENTER VAULT PIN',
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
              'Enter the Master PIN used when this vault was created.',
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
              keyboardType: TextInputType.number,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                color: VaultColors.textPrimary,
                letterSpacing: 6,
              ),
              textAlign: TextAlign.center,
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
                hintText: '\u2022\u2022\u2022\u2022\u2022\u2022',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
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

              // ── Animated Vault Icon ──
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
                      child: Container(
                        width: 72,
                        height: 72,
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
                            color: VaultColors.phosphorGreenDim,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 32,
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
                'ForgeVault',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: VaultColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'YOUR DATA. YOUR DEVICE. ZERO CLOUD.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: VaultColors.phosphorGreen,
                  letterSpacing: 3,
                ),
              ),

              const Spacer(flex: 2),

              // ── Initialize Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onInitialize,
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

              // ── Restore Button ──
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
