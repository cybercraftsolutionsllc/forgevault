import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/database_service.dart';
import '../../core/services/revenuecat_service.dart';
import '../../core/services/sync_service.dart';
import '../../providers/providers.dart';
import '../../main.dart';
import '../../theme/theme.dart';

/// Backup Center â€” E2EE encrypted vault export/import.
/// Portable backups are a PRO-only feature.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exportLoading = false;
  bool _importLoading = false;

  /// Pro status â€” driven reactively by RevenueCatService.isProNotifier.
  bool get _isPro => RevenueCatService().isProNotifier.value;

  Future<void> _setProState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', value);
    RevenueCatService().isProNotifier.value = value;
  }

  // â”€â”€ Export Dialog Flow â”€â”€
  Future<void> _handleExport() async {
    // â”€â”€ Sovereignty Gate: block empty vault exports â”€â”€
    final db = DatabaseService.instance;
    if (db.isOpen) {
      final bioProgress = await db.calculateBioProgress();
      if (bioProgress < 0.05) {
        showSafeSnackBar(
          SnackBar(
            content: Text(
              'Error: Vault must contain core identity data before exporting.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }

    // Show password dialog first
    final password = await _showExportPasswordDialog();
    if (password == null) return;

    setState(() => _exportLoading = true);
    try {
      final masterPin = ref.read(masterPinProvider);
      await SyncService.instance.exportEncryptedVault(
        password,
        masterPin: masterPin,
      );
      showSafeSnackBar(
        SnackBar(
          content: Text(
            'Vault exported successfully.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: VaultColors.phosphorGreen.withValues(alpha: 0.85),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[BackupScreen] Export failed: $e');
      debugPrint('[BackupScreen] Stack trace: $stackTrace');
      _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exportLoading = false);
    }
  }

  // â”€â”€ Import Dialog Flow â”€â”€
  Future<void> _handleImport() async {
    // 1. Pick file first (load bytes into RAM for Android compat)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Select .forge Artifact',
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (!file.name.endsWith('.forge')) {
      _showError('Invalid file format. Only .forge files are supported.');
      return;
    }

    // 2. Aggressively extract bytes â€” RAM first, path fallback
    Uint8List? fileBytes = file.bytes;
    if (fileBytes == null && file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }
    if (fileBytes == null) {
      _showError(
        'OS denied access to file bytes. Try moving the file to local storage.',
      );
      return;
    }

    // 3. Show password dialog
    if (!mounted) return;
    final password = await _showDecryptPasswordDialog();
    if (password == null) return;

    // 4. Import from bytes
    setState(() => _importLoading = true);
    try {
      await SyncService.instance.importFromBytes(fileBytes, password);
      if (mounted) {
        showSafeSnackBar(
          SnackBar(
            content: Text(
              'Vault restored from encrypted backup.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: VaultColors.phosphorGreen.withValues(alpha: 0.85),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
              'Decryption Failed',
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
      if (mounted) setState(() => _importLoading = false);
    }
  }

  /// Export dialog: 'Secure Your Backup' with Create + Confirm password fields.
  Future<String?> _showExportPasswordDialog() {
    final createCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Text(
          'SECURE YOUR BACKUP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: VaultColors.phosphorGreenDim,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a password to encrypt your .forge artifact. '
              'You will need this password to restore.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VaultColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDialogField(
              controller: createCtrl,
              hint: 'Create password',
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 10),
            _buildDialogField(
              controller: confirmCtrl,
              hint: 'Confirm password',
              icon: Icons.lock_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              final pw = createCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              if (pw.isEmpty) {
                _showError('Password is required.');
                return;
              }
              if (pw.length < 6) {
                _showError('Password must be at least 6 characters.');
                return;
              }
              if (pw != confirm) {
                _showError('Passwords do not match.');
                return;
              }
              Navigator.of(ctx).pop(pw);
            },
            icon: const Icon(Icons.lock_outlined, size: 16),
            label: Text(
              'Export',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: VaultColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Import dialog: 'Decrypt Artifact' with single password field.
  Future<String?> _showDecryptPasswordDialog() {
    final pwCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Text(
          'DECRYPT ARTIFACT',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: VaultColors.phosphorGreenDim,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the password used when this .forge backup was created.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VaultColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDialogField(
              controller: pwCtrl,
              hint: 'Backup Password',
              icon: Icons.vpn_key_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              final pw = pwCtrl.text.trim();
              if (pw.isEmpty) {
                _showError('Password is required.');
                return;
              }
              Navigator.of(ctx).pop(pw);
            },
            icon: const Icon(Icons.lock_open_rounded, size: 16),
            label: Text(
              'Decrypt & Restore',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: VaultColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        color: VaultColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: VaultColors.textMuted,
        ),
        prefixIcon: Icon(icon, size: 18, color: VaultColors.textMuted),
        filled: true,
        fillColor: VaultColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          borderSide: BorderSide(color: VaultColors.primaryLight, width: 1.5),
        ),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    showSafeSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: VaultColors.destructive.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // â”€â”€ RevenueCat Pro Upgrade Modal â”€â”€
  void _showUpgradeModal() {
    final promoCtrl = TextEditingController();
    final rc = RevenueCatService();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ForgeVault PRO',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
        content: ValueListenableBuilder<bool>(
          valueListenable: rc.isProNotifier,
          builder: (context, isPro, _) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── PRO UNLOCKED badge ──
                if (isPro) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: VaultColors.phosphorGreen.withValues(alpha: 0.1),
                      border: Border.all(
                        color: VaultColors.phosphorGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: VaultColors.phosphorGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRO UNLOCKED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: VaultColors.phosphorGreen,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Unlock portable encrypted backups, priority '
                  'support, and future PRO features.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VaultColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // â”€â”€ RevenueCat Paywall (supported platforms only) â”€â”€
                if (rc.isSupported) ...[
                  if (!isPro)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          try {
                            await rc.presentPaywall();
                            // Re-check Pro status after paywall
                            final prefs = await SharedPreferences.getInstance();
                            final newPro = prefs.getBool('isPro') ?? false;
                            if (newPro && mounted) _setProState(true);
                          } catch (e) {
                            if (!e.toString().contains('cancelled') &&
                                mounted) {
                              showSafeSnackBar(
                                SnackBar(
                                  content: Text(
                                    'RC Error: $e',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: VaultColors.destructive
                                      .withValues(alpha: 0.9),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.storefront_rounded, size: 18),
                        label: Text(
                          'View Premium Plans',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          try {
                            await rc.showCustomerCenter();
                          } catch (e) {
                            if (!e.toString().contains('cancelled') &&
                                mounted) {
                              showSafeSnackBar(
                                SnackBar(
                                  content: Text(
                                    'RC Error: $e',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: VaultColors.destructive
                                      .withValues(alpha: 0.9),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.manage_accounts_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Manage Subscription',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD700),
                          side: BorderSide(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Restore Purchases
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await rc.restorePurchases();
                          final prefs = await SharedPreferences.getInstance();
                          final newPro = prefs.getBool('isPro') ?? false;
                          if (newPro && mounted) {
                            _setProState(true);
                            if (mounted) {
                              showSafeSnackBar(
                                SnackBar(
                                  content: Text(
                                    'âœ… Purchases restored! PRO unlocked.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: VaultColors.phosphorGreen
                                      .withValues(alpha: 0.9),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (!e.toString().contains('cancelled') && mounted) {
                            showSafeSnackBar(
                              SnackBar(
                                content: Text(
                                  'RC Error: $e',
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                                backgroundColor: VaultColors.destructive
                                    .withValues(alpha: 0.9),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        'Restore Purchases',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: VaultColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],

                // â”€â”€ Windows/Web Fallback â”€â”€
                if (!rc.isSupported) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: VaultColors.background,
                      border: Border.all(color: VaultColors.border, width: 0.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: VaultColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Premium features are managed via our '
                            'mobile apps. Purchase PRO on iOS or '
                            'Android, and your status will '
                            'automatically sync to this PC when you '
                            'import your encrypted .forge backup.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: VaultColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // â”€â”€ Promo Code (always available) â”€â”€
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: VaultColors.border, thickness: 0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: VaultColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: VaultColors.border, thickness: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: promoCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: VaultColors.textPrimary,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'PROMO CODE',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: VaultColors.textMuted,
                      letterSpacing: 2,
                    ),
                    prefixIcon: Icon(
                      Icons.confirmation_number_outlined,
                      size: 18,
                      color: VaultColors.textMuted,
                    ),
                    filled: true,
                    fillColor: VaultColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                        color: Color(0xFFFFD700),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final code = promoCtrl.text.trim().toUpperCase();
                      if (code != 'FOUNDER2026') {
                        showSafeSnackBar(
                          SnackBar(
                            content: Text(
                              'Invalid promo code.',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                            backgroundColor: VaultColors.destructive.withValues(
                              alpha: 0.9,
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.of(ctx).pop();
                      _setProState(true);
                      showSafeSnackBar(
                        SnackBar(
                          content: Text(
                            'ðŸŽ‰ Founder code accepted! PRO unlocked '
                            'forever.',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: VaultColors.phosphorGreen.withValues(
                            alpha: 0.9,
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.redeem_rounded, size: 16),
                    label: Text(
                      'Redeem Code',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD700),
                      side: BorderSide(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: RevenueCatService().isProNotifier,
      builder: (context, isPro, _) => Scaffold(
        backgroundColor: VaultColors.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // â”€â”€ Header â”€â”€
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            VaultColors.primaryDark,
                            VaultColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: VaultColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BACKUPS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: VaultColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AES-256-GCM End-to-End Encryption',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: VaultColors.phosphorGreenDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // â”€â”€ PRO Gate Banner â”€â”€
              if (!_isPro) ...[_buildProBanner(), const SizedBox(height: 20)],

              // â”€â”€ Export Card â”€â”€
              _buildCard(
                icon: Icons.file_upload_outlined,
                title: 'Export Encrypted Backup',
                description:
                    'Create a portable .forge artifact encrypted with your '
                    'password. Safe to store in cloud drives, email, or USB.',
                locked: !_isPro,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: !_isPro || _exportLoading ? null : _handleExport,
                    icon: _exportLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: VaultColors.textMuted,
                            ),
                          )
                        : const Icon(Icons.lock_outlined, size: 18),
                    label: Text(
                      _exportLoading ? 'Encrypting...' : 'Export .forge Backup',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isPro
                          ? VaultColors.primary
                          : VaultColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                child: Text(
                  'Note: Cloud drives may strip the .forge extension upon '
                  'upload. Rename locally to restore.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: VaultColors.textMuted.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // â”€â”€ Import Card â”€â”€
              _buildCard(
                icon: Icons.file_download_outlined,
                title: 'Restore from Backup',
                description:
                    'Select a .forge file and decrypt it with the password '
                    'used during export. This will replace your local vault.',
                locked: !_isPro,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: !_isPro || _importLoading ? null : _handleImport,
                    icon: _importLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: VaultColors.textMuted,
                            ),
                          )
                        : const Icon(Icons.vpn_key_outlined, size: 18),
                    label: Text(
                      _importLoading
                          ? 'Decrypting...'
                          : 'Select .forge Artifact',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isPro
                          ? VaultColors.primaryLight
                          : VaultColors.textMuted,
                      side: BorderSide(color: VaultColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // â”€â”€ Security Notice â”€â”€
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VaultColors.phosphorGreenDim.withValues(alpha: 0.3),
                  ),
                  color: VaultColors.phosphorGreen.withValues(alpha: 0.05),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: VaultColors.phosphorGreenDim,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your password never leaves this device. The .forge file '
                        'is encrypted with AES-256-GCM â€” even if intercepted, '
                        'the data is unreadable without your password.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: VaultColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ PRO Upgrade Banner â”€â”€
  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to ForgeVault PRO',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Portable encrypted backups are a premium feature.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: VaultColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _showUpgradeModal,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'UNLOCK PRO',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
    bool locked = false,
  }) {
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: VaultDecorations.metallicCard(borderRadius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: VaultColors.primaryLight.withValues(alpha: 0.15),
                  ),
                  child: Icon(icon, color: VaultColors.primaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VaultColors.textPrimary,
                    ),
                  ),
                ),
                if (locked)
                  Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: VaultColors.textMuted,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VaultColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
