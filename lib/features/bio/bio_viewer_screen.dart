import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme.dart';

/// Bio Viewer — expandable accordion view of all Isar collections.
class BioViewerScreen extends StatelessWidget {
  const BioViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(
          'MY BIO',
          style: GoogleFonts.inter(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ──
          Text(
            'Your Living\nLife Bio',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: VaultColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything the Forge has synthesized from your data.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: VaultColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // ── Accordion Sections ──
          _BioSection(
            icon: Icons.person_outline,
            title: 'Identity',
            subtitle: 'Core profile and immutable traits',
          ),
          _BioSection(
            icon: Icons.timeline_outlined,
            title: 'Timeline',
            subtitle: 'Life events in chronological order',
          ),
          _BioSection(
            icon: Icons.warning_amber_outlined,
            title: 'Troubles',
            subtitle: 'Active and resolved issues',
          ),
          _BioSection(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Finances',
            subtitle: 'Assets, debts, and transactions',
          ),
          _BioSection(
            icon: Icons.people_outline,
            title: 'Relationships',
            subtitle: 'People and trust levels',
          ),
          _BioSection(
            icon: Icons.favorite_outline,
            title: 'Health',
            subtitle: 'Conditions, medications, allergies',
          ),
          _BioSection(
            icon: Icons.flag_outlined,
            title: 'Goals',
            subtitle: 'Targets and progress tracking',
          ),
          _BioSection(
            icon: Icons.repeat_outlined,
            title: 'Habits & Vices',
            subtitle: 'Patterns and behaviors',
          ),
          _BioSection(
            icon: Icons.photo_library_outlined,
            title: 'Verified Photo Gallery',
            subtitle: 'Real photos with EXIF validation',
          ),
        ],
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BioSection({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: VaultDecorations.metallicCard(borderRadius: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: VaultColors.primaryLight, size: 22),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: VaultColors.textMuted,
            ),
          ),
          iconColor: VaultColors.textMuted,
          collapsedIconColor: VaultColors.textMuted,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No data yet. Vacuum files to populate.',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: VaultColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
