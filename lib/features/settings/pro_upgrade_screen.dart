import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/providers.dart';
import '../../theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Upgrade to Pro — sleek monetization screen.
///
/// Gates Biometric Lock and Vault Sync behind a $29.99 lifetime purchase.
/// Uses Riverpod state (`isProUnlocked`) for mock purchase flow.
class ProUpgradeScreen extends ConsumerStatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  ConsumerState<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends ConsumerState<ProUpgradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shieldController;
  late Animation<double> _shieldPulse;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shieldPulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shieldController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    setState(() => _purchasing = true);
    HapticFeedback.heavyImpact();

    // Simulate purchase processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Persist Pro status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPro', true);

      ref.read(isProUnlockedProvider.notifier).state = true;
      setState(() => _purchasing = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pro Unlocked!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(isProUnlockedProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(
          'UPGRADE',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── Animated Shield ──
            AnimatedBuilder(
              animation: _shieldPulse,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        VaultColors.phosphorGreen.withValues(
                          alpha: _shieldPulse.value * 0.15,
                        ),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: VaultColors.phosphorGreen.withValues(
                          alpha: _shieldPulse.value * 0.08,
                        ),
                        blurRadius: 50,
                        spreadRadius: 15,
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
                          color: isPro
                              ? VaultColors.phosphorGreen
                              : VaultColors.border,
                          width: isPro ? 2 : 0.5,
                        ),
                      ),
                      child: Icon(
                        isPro
                            ? Icons.verified_user_rounded
                            : Icons.shield_rounded,
                        size: 36,
                        color: isPro
                            ? VaultColors.phosphorGreen
                            : VaultColors.primaryLight,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Title ──
            Text(
              isPro ? 'PRO UNLOCKED' : 'VITAVAULT PRO',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: VaultColors.textPrimary,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isPro
                  ? 'All fortress features are active.'
                  : 'Unlock the full fortress.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VaultColors.textMuted,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 40),

            // ── Feature Cards ──
            _buildFeatureCard(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric Lock',
              description:
                  'FaceID, TouchID, or Windows Hello — bypass your PIN with hardware biometrics.',
              isActive: isPro,
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.sync_lock_rounded,
              title: 'Encrypted Vault Sync',
              description:
                  'AES-256-GCM encrypted sync via your own cloud folder. Zero-trust. Zero-knowledge.',
              isActive: isPro,
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.support_agent_rounded,
              title: 'Priority Support',
              description:
                  'Direct access to the development team for bug reports and feature requests.',
              isActive: isPro,
              onTap: isPro
                  ? () => launchUrl(
                      Uri.parse(
                        'mailto:cyber.craft@craftedcybersolutions.com?subject=VitaVault%20Pro%20Support',
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 40),

            // ── Purchase Button ──
            if (!isPro)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _purchasing ? null : _handlePurchase,
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
                  child: _purchasing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VaultColors.phosphorGreen,
                          ),
                        )
                      : Text(
                          'PURCHASE FOR \$29.99',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: VaultDecorations.glowBorder(borderRadius: 16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: VaultColors.phosphorGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIFETIME PRO',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: VaultColors.phosphorGreen,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // ── Fine Print ──
            Text(
              'One-time purchase • No subscriptions • No cloud accounts\nAll data stays on YOUR device.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: VaultColors.textMuted.withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? VaultColors.phosphorGreenDim : VaultColors.border,
            width: isActive ? 1 : 0.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    VaultColors.primary.withValues(alpha: 0.15),
                    VaultColors.surface,
                  ]
                : [VaultColors.surface, VaultColors.cardSurface],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? VaultColors.primary.withValues(alpha: 0.3)
                    : VaultColors.surfaceVariant,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? VaultColors.phosphorGreen
                    : VaultColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: VaultColors.phosphorGreen.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: VaultColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
