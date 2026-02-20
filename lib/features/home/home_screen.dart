import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/providers.dart';
import '../../theme/theme.dart';

/// Home Dashboard — the primary screen after authentication.
///
/// Layout:
///   Top: Progress ring showing "Life Bio Completeness"
///   Middle: "Quick AI Query" text input
///   Bottom: Horizontal scrolling cards (Recent Vacuums, Money, Troubles)
class HomeScreen extends ConsumerWidget {
  final ValueChanged<int>? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bioAsync = ref.watch(bioProgressProvider);
    final progress = bioAsync.valueOrNull ?? 0.0;

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Bio Completeness Ring ──
            Center(
              child: _BioCOmpletenessRing(
                completeness: (progress * 100).toInt(),
              ),
            ),

            const SizedBox(height: 32),

            // ── Quick AI Query ──
            GestureDetector(
              onTap: () => onSwitchTab?.call(3), // Switch to Nexus tab
              child: AbsorbPointer(child: _QuickQueryInput()),
            ),

            const SizedBox(height: 32),

            // ── Section: Recent Activity ──
            Text(
              'RECENT ACTIVITY',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VaultColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  _DashboardCard(
                    icon: Icons.download_rounded,
                    title: 'Recent Vacuums',
                    subtitle: ref
                        .watch(timelineStreamProvider)
                        .when(
                          data: (events) => events.isEmpty
                              ? 'No files ingested yet'
                              : '${events.length} timeline events',
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error loading',
                        ),
                    accentColor: VaultColors.primaryLight,
                  ),
                  _DashboardCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Money Snapshot',
                    subtitle: ref
                        .watch(financesStreamProvider)
                        .when(
                          data: (records) => records.isEmpty
                              ? '\$0.00 net worth'
                              : '${records.length} finance records',
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error loading',
                        ),
                    accentColor: VaultColors.phosphorGreen,
                  ),
                  _DashboardCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Trouble Alerts',
                    subtitle: ref
                        .watch(troublesStreamProvider)
                        .when(
                          data: (troubles) => troubles.isEmpty
                              ? 'No active troubles'
                              : '${troubles.length} active troubles',
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error loading',
                        ),
                    accentColor: VaultColors.destructive,
                  ),
                  _DashboardCard(
                    icon: Icons.favorite_outline,
                    title: 'Health Status',
                    subtitle: ref
                        .watch(healthStreamProvider)
                        .when(
                          data: (health) => health == null
                              ? 'No health data yet'
                              : 'Health profile active',
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error loading',
                        ),
                    accentColor: VaultColors.primaryLight,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Section: Quick Actions ──
            Text(
              'QUICK ACTIONS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VaultColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.file_upload_outlined,
                    label: 'VACUUM',
                    onTap: () => onSwitchTab?.call(1), // Vacuum tab
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.auto_stories_outlined,
                    label: 'VIEW BIO',
                    onTap: () => onSwitchTab?.call(2), // Bio tab
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.chat_outlined,
                    label: 'NEXUS',
                    onTap: () => onSwitchTab?.call(3), // Nexus tab
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Audit Log Preview ──
            Text(
              'AUDIT LOG',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VaultColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: VaultDecorations.metallicCard(),
              child: Center(
                child: Text(
                  'No audit entries yet.\nVacuum a file to begin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: VaultColors.textMuted,
                    height: 1.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Bio Completeness Ring Widget ──

class _BioCOmpletenessRing extends StatelessWidget {
  final int completeness;
  const _BioCOmpletenessRing({required this.completeness});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: VaultColors.phosphorGlow,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RingPainter(completeness / 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$completeness%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: VaultColors.phosphorGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LIFE BIO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: VaultColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    final bgPaint = Paint()
      ..color = VaultColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          VaultColors.primaryDark,
          VaultColors.primaryLight,
          VaultColors.phosphorGreen,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Quick Query Input ──

class _QuickQueryInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VaultDecorations.metallicCard(borderRadius: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        style: GoogleFonts.inter(color: VaultColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ask your vault anything...',
          hintStyle: GoogleFonts.inter(
            color: VaultColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.auto_awesome_outlined,
            color: VaultColors.phosphorGreenDim,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}

// ── Dashboard Card Widget ──

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: VaultDecorations.metallicCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accentColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: VaultColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button ──

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: VaultDecorations.metallicCard(borderRadius: 12),
        child: Column(
          children: [
            Icon(icon, color: VaultColors.primaryLight, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: VaultColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
