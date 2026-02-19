import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/schemas/finance_record.dart';
import '../../core/database/schemas/goal.dart';
import '../../core/database/schemas/habit_vice.dart';
import '../../core/database/schemas/relationship_node.dart';
import '../../core/database/schemas/timeline_event.dart';
import '../../core/database/schemas/trouble.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';

/// Bio Viewer — reactive accordion view of all Isar collections.
///
/// Each section streams live data from Isar via [StreamProvider]s.
/// The UI auto-updates whenever the Forge commits new records.
class BioViewerScreen extends ConsumerWidget {
  const BioViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          // ── Identity ──
          _IdentitySection(ref: ref),

          // ── Timeline ──
          _ListStreamSection<TimelineEvent>(
            icon: Icons.timeline_outlined,
            title: 'Timeline',
            subtitle: 'Life events in chronological order',
            provider: timelineStreamProvider,
            ref: ref,
            itemBuilder: (e) =>
                '${e.eventDate.toIso8601String().split('T').first}  ${e.title}',
          ),

          // ── Troubles ──
          _ListStreamSection<Trouble>(
            icon: Icons.warning_amber_outlined,
            title: 'Troubles',
            subtitle: 'Active and resolved issues',
            provider: troublesStreamProvider,
            ref: ref,
            itemBuilder: (t) =>
                '${t.title} — Severity ${t.severity}/10${t.isResolved ? ' ✓' : ''}',
          ),

          // ── Finances ──
          _ListStreamSection<FinanceRecord>(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Finances',
            subtitle: 'Assets, debts, and transactions',
            provider: financesStreamProvider,
            ref: ref,
            itemBuilder: (f) =>
                '${f.assetOrDebtName} — \$${f.amount.toStringAsFixed(2)} (${f.isDebt ? "Debt" : "Asset"})',
          ),

          // ── Relationships ──
          _ListStreamSection<RelationshipNode>(
            icon: Icons.people_outline,
            title: 'Relationships',
            subtitle: 'People and trust levels',
            provider: relationshipsStreamProvider,
            ref: ref,
            itemBuilder: (r) =>
                '${r.personName} — ${r.relationType} (Trust ${r.trustLevel}/10)',
          ),

          // ── Health ──
          _HealthSection(ref: ref),

          // ── Goals ──
          _ListStreamSection<Goal>(
            icon: Icons.flag_outlined,
            title: 'Goals',
            subtitle: 'Targets and progress tracking',
            provider: goalsStreamProvider,
            ref: ref,
            itemBuilder: (g) =>
                '${g.title} — ${g.progress}%${g.isCompleted ? ' ✓' : ''}',
          ),

          // ── Habits & Vices ──
          _ListStreamSection<HabitVice>(
            icon: Icons.repeat_outlined,
            title: 'Habits & Vices',
            subtitle: 'Patterns and behaviors',
            provider: habitsStreamProvider,
            ref: ref,
            itemBuilder: (h) =>
                '${h.name} (${h.isVice ? "Vice" : "Habit"}) — ${h.frequency}',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Identity Section (single record)
// ─────────────────────────────────────────────────────────────

class _IdentitySection extends StatelessWidget {
  final WidgetRef ref;
  const _IdentitySection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final identityAsync = ref.watch(identityStreamProvider);

    return _BioAccordion(
      icon: Icons.person_outline,
      title: 'Identity',
      subtitle: 'Core profile and immutable traits',
      children: [
        identityAsync.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (identity) {
            if (identity == null) return _emptyTile();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dataRow('Name', identity.fullName),
                  _dataRow('Location', identity.location),
                  _dataRow(
                    'Born',
                    identity.dateOfBirth?.toIso8601String().split('T').first ??
                        '—',
                  ),
                  if (identity.immutableTraits != null &&
                      identity.immutableTraits!.isNotEmpty)
                    _dataRow('Traits', identity.immutableTraits!.join(', ')),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Health Section (single record)
// ─────────────────────────────────────────────────────────────

class _HealthSection extends StatelessWidget {
  final WidgetRef ref;
  const _HealthSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(healthStreamProvider);

    return _BioAccordion(
      icon: Icons.favorite_outline,
      title: 'Health',
      subtitle: 'Conditions, medications, allergies',
      children: [
        healthAsync.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (hp) {
            if (hp == null) return _emptyTile();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hp.conditions != null && hp.conditions!.isNotEmpty)
                    _dataRow('Conditions', hp.conditions!.join(', ')),
                  if (hp.medications != null && hp.medications!.isNotEmpty)
                    _dataRow('Medications', hp.medications!.join(', ')),
                  if (hp.allergies != null && hp.allergies!.isNotEmpty)
                    _dataRow('Allergies', hp.allergies!.join(', ')),
                  _dataRow('Blood Type', hp.bloodType ?? '—'),
                  if (hp.primaryPhysician != null)
                    _dataRow('Physician', hp.primaryPhysician!),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Generic List Section (streams a List<T>)
// ─────────────────────────────────────────────────────────────

class _ListStreamSection<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final StreamProvider<List<T>> provider;
  final WidgetRef ref;
  final String Function(T) itemBuilder;

  const _ListStreamSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.ref,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(provider);

    return _BioAccordion(
      icon: icon,
      title: title,
      subtitle: subtitle,
      children: [
        asyncList.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (list) {
            if (list.isEmpty) return _emptyTile();
            return Column(
              children: list
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•  ',
                            style: TextStyle(
                              color: VaultColors.primaryLight,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              itemBuilder(item),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: VaultColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Accordion Container
// ─────────────────────────────────────────────────────────────

class _BioAccordion extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _BioAccordion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
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
          children: children,
        ),
      ),
    );
  }
}

// ── Shared Utility Widgets ──

Widget _loadingTile() => const Padding(
  padding: EdgeInsets.all(16),
  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
);

Widget _errorTile(Object error) => Padding(
  padding: const EdgeInsets.all(16),
  child: Text(
    'Error: $error',
    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.redAccent),
  ),
);

Widget _emptyTile() => Padding(
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
);

Widget _dataRow(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: VaultColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value.isEmpty ? '—' : value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: VaultColors.textPrimary,
          ),
        ),
      ),
    ],
  ),
);
