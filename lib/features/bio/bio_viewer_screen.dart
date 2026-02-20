import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/database_service.dart';
import '../../core/database/schemas/core_identity.dart';
import '../../core/database/schemas/finance_record.dart';
import '../../core/database/schemas/goal.dart';
import '../../core/database/schemas/habit_vice.dart';
import '../../core/database/schemas/relationship_node.dart';
import '../../core/database/schemas/timeline_event.dart';
import '../../core/database/schemas/trouble.dart';
import '../../core/database/schemas/medical_ledger.dart';
import '../../core/database/schemas/career_ledger.dart';
import '../../core/database/schemas/asset_ledger.dart';
import '../../core/database/schemas/relational_web.dart';
import '../../core/database/schemas/psyche_profile.dart';
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

          // ── Career & Education ──
          _IdentityListSection(
            ref: ref,
            icon: Icons.work_outline,
            title: 'Career & Education',
            subtitle: 'Jobs, roles, degrees, and certifications',
            listExtractors: [
              _ListDescriptor('Job History', (id) => id.jobHistory),
              _ListDescriptor('Education', (id) => id.educationHistory),
            ],
          ),

          // ── Location History ──
          _IdentityListSection(
            ref: ref,
            icon: Icons.map_outlined,
            title: 'Location History',
            subtitle: 'Past and current cities and addresses',
            listExtractors: [
              _ListDescriptor('Locations', (id) => id.locationHistory),
            ],
          ),

          // ── Family & Lineage ──
          _IdentityListSection(
            ref: ref,
            icon: Icons.account_tree_outlined,
            title: 'Family & Lineage',
            subtitle: 'Ancestry, parents, children, heritage',
            listExtractors: [
              _ListDescriptor('Lineage', (id) => id.familyLineage),
            ],
          ),

          // ── Digital Footprint ──
          _IdentityListSection(
            ref: ref,
            icon: Icons.alternate_email,
            title: 'Digital Footprint',
            subtitle: 'Social media, URLs, and online profiles',
            listExtractors: [
              _ListDescriptor('Profiles', (id) => id.digitalFootprint),
            ],
          ),

          // ── Timeline ──
          _ListStreamSection<TimelineEvent>(
            icon: Icons.timeline_outlined,
            title: 'Timeline',
            subtitle: 'Life events in chronological order',
            provider: timelineStreamProvider,
            ref: ref,
            itemBuilder: (e) {
              try {
                final dateStr = e.eventDate.toIso8601String().split('T').first;
                return '$dateStr  ${e.title}';
              } catch (_) {
                return '???  ${e.title}';
              }
            },
            idExtractor: (e) => e.id,
            onDismissed: (id) =>
                DatabaseService.instance.deleteTimelineEvent(id),
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
            idExtractor: (t) => t.id,
            onDismissed: (id) => DatabaseService.instance.deleteTrouble(id),
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
            idExtractor: (g) => g.id,
            onDismissed: (id) => DatabaseService.instance.deleteGoal(id),
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
            idExtractor: (h) => h.id,
            onDismissed: (id) => DatabaseService.instance.deleteHabitVice(id),
          ),

          // ── Medical Ledger ──
          _LedgerSection<MedicalLedger>(
            ref: ref,
            icon: Icons.medical_services_outlined,
            title: 'Medical Ledger',
            subtitle: 'Surgeries, genetics, immunizations, dental',
            provider: medicalLedgerStreamProvider,
            fieldExtractors: [
              _LedgerField('Surgeries', (m) => m.surgeries),
              _LedgerField('Genetics', (m) => m.genetics),
              _LedgerField('Vital Baselines', (m) => m.vitalBaselines),
              _LedgerField('Vision Rx', (m) => m.visionRx),
              _LedgerField('Family Medical Hx', (m) => m.familyMedicalHistory),
              _LedgerField('Bloodwork', (m) => m.bloodwork),
              _LedgerField('Immunizations', (m) => m.immunizations),
              _LedgerField('Dental History', (m) => m.dentalHistory),
            ],
          ),

          // ── Career Ledger ──
          _LedgerSection<CareerLedger>(
            ref: ref,
            icon: Icons.work_outline,
            title: 'Career Ledger',
            subtitle: 'Jobs, degrees, certs, skills, projects',
            provider: careerLedgerStreamProvider,
            fieldExtractors: [
              _LedgerField('Jobs', (c) => c.jobs),
              _LedgerField('Degrees', (c) => c.degrees),
              _LedgerField('Certifications', (c) => c.certifications),
              _LedgerField('Clearances', (c) => c.clearances),
              _LedgerField('Skills', (c) => c.skills),
              _LedgerField('Projects', (c) => c.projects),
            ],
          ),

          // ── Asset Ledger ──
          _LedgerSection<AssetLedger>(
            ref: ref,
            icon: Icons.account_balance_outlined,
            title: 'Asset Ledger',
            subtitle: 'Property, vehicles, investments, insurance',
            provider: assetLedgerStreamProvider,
            fieldExtractors: [
              _LedgerField('Real Estate', (a) => a.realEstate),
              _LedgerField('Vehicles', (a) => a.vehicles),
              _LedgerField('Digital Assets', (a) => a.digitalAssets),
              _LedgerField('Insurance', (a) => a.insurance),
              _LedgerField('Investments', (a) => a.investments),
              _LedgerField('Valuables', (a) => a.valuables),
            ],
          ),

          // ── Relational Web ──
          _LedgerSection<RelationalWeb>(
            ref: ref,
            icon: Icons.hub_outlined,
            title: 'Relational Web',
            subtitle: 'Family, mentors, colleagues, friends',
            provider: relationalWebStreamProvider,
            fieldExtractors: [
              _LedgerField('Family', (r) => r.family),
              _LedgerField('Mentors', (r) => r.mentors),
              _LedgerField('Adversaries', (r) => r.adversaries),
              _LedgerField('Colleagues', (r) => r.colleagues),
              _LedgerField('Friends', (r) => r.friends),
            ],
          ),

          // ── Psyche Profile ──
          _LedgerSection<PsycheProfile>(
            ref: ref,
            icon: Icons.psychology_outlined,
            title: 'Psyche Profile',
            subtitle: 'Beliefs, personality, fears, motivations',
            provider: psycheProfileStreamProvider,
            fieldExtractors: [
              _LedgerField('Beliefs', (p) => p.beliefs),
              _LedgerField('Personality', (p) => p.personality),
              _LedgerField('Fears', (p) => p.fears),
              _LedgerField('Motivations', (p) => p.motivations),
              _LedgerField('Strengths', (p) => p.strengths),
              _LedgerField('Weaknesses', (p) => p.weaknesses),
            ],
            scalarExtractor: (p) {
              final parts = <String>[];
              if (p.enneagram != null && p.enneagram!.isNotEmpty) {
                parts.add('Enneagram: ${p.enneagram}');
              }
              if (p.mbti != null && p.mbti!.isNotEmpty) {
                parts.add('MBTI: ${p.mbti}');
              }
              return parts.isEmpty ? null : parts.join('  •  ');
            },
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
                  // Edit button row
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: VaultColors.primaryLight,
                      ),
                      onPressed: () =>
                          _showEditIdentityDialog(context, identity),
                      tooltip: 'Edit Identity',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
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

  void _showEditIdentityDialog(BuildContext context, CoreIdentity identity) {
    final nameCtrl = TextEditingController(text: identity.fullName);
    final locationCtrl = TextEditingController(text: identity.location);
    final bornCtrl = TextEditingController(
      text: identity.dateOfBirth?.toIso8601String().split('T').first ?? '',
    );
    final traitsCtrl = TextEditingController(
      text: identity.immutableTraits?.join('\n') ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: VaultColors.border),
        ),
        title: Text(
          'Edit Identity',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: VaultColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField('Name', nameCtrl),
              const SizedBox(height: 12),
              _editField('Location', locationCtrl),
              const SizedBox(height: 12),
              _editField('Born (YYYY-MM-DD)', bornCtrl),
              const SizedBox(height: 12),
              _editField('Traits (one per line)', traitsCtrl, maxLines: 4),
            ],
          ),
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
            onPressed: () async {
              identity.fullName = nameCtrl.text.trim();
              identity.location = locationCtrl.text.trim();
              if (bornCtrl.text.trim().isNotEmpty) {
                try {
                  identity.dateOfBirth = DateTime.parse(bornCtrl.text.trim());
                } catch (_) {}
              }
              final lines = traitsCtrl.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              identity.immutableTraits = lines.isEmpty ? null : lines;
              identity.lastUpdated = DateTime.now();

              final db = DatabaseService.instance.db;
              await db.writeTxn(() async => db.coreIdentitys.put(identity));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _editField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 13, color: VaultColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          color: VaultColors.textMuted,
        ),
        filled: true,
        fillColor: VaultColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: VaultColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: VaultColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: VaultColors.primary),
        ),
      ),
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
                  if (hp.labResults?.isNotEmpty == true)
                    _dataRow('Lab Results', hp.labResults!.join('\n•  ')),
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
// Generic Ledger Section (single-record stream with List<String> fields)
// ─────────────────────────────────────────────────────────────

class _LedgerField<T> {
  final String label;
  final List<String>? Function(T) extractor;
  const _LedgerField(this.label, this.extractor);
}

class _LedgerSection<T> extends StatelessWidget {
  final WidgetRef ref;
  final IconData icon;
  final String title;
  final String subtitle;
  final StreamProvider<T?> provider;
  final List<_LedgerField<T>> fieldExtractors;
  final String? Function(T)? scalarExtractor;

  const _LedgerSection({
    required this.ref,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.fieldExtractors,
    this.scalarExtractor,
  });

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(provider);

    return _BioAccordion(
      icon: icon,
      title: title,
      subtitle: subtitle,
      children: [
        asyncData.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (record) {
            if (record == null) return _emptyTile();

            final rows = <Widget>[];

            // Scalar row (e.g. MBTI / Enneagram for Psyche)
            if (scalarExtractor != null) {
              final scalar = scalarExtractor!(record);
              if (scalar != null) {
                rows.add(_dataRow('Type', scalar));
              }
            }

            // List<String> field rows
            for (final field in fieldExtractors) {
              final list = field.extractor(record);
              if (list != null && list.isNotEmpty) {
                rows.add(_dataRow(field.label, list.join('\n•  ')));
              }
            }

            if (rows.isEmpty) return _emptyTile();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rows,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Identity Derived List Sections (Career, Location, Lineage, Digital)
// ─────────────────────────────────────────────────────────────

class _ListDescriptor {
  final String label;
  final List<String>? Function(CoreIdentity) extractor;
  const _ListDescriptor(this.label, this.extractor);
}

class _IdentityListSection extends StatelessWidget {
  final WidgetRef ref;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_ListDescriptor> listExtractors;

  const _IdentityListSection({
    required this.ref,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.listExtractors,
  });

  @override
  Widget build(BuildContext context) {
    final identityAsync = ref.watch(identityStreamProvider);

    return _BioAccordion(
      icon: icon,
      title: title,
      subtitle: subtitle,
      children: [
        identityAsync.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (identity) {
            if (identity == null) return _emptyTile();
            final widgets = <Widget>[];
            for (final desc in listExtractors) {
              final items = desc.extractor(identity);
              if (items != null && items.isNotEmpty) {
                widgets.add(
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desc.label.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: VaultColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final item in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
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
                                    item,
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
                      ],
                    ),
                  ),
                );
              }
            }
            if (widgets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No data extracted yet.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: VaultColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(children: widgets),
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
  final int Function(T)? idExtractor;
  final Future<void> Function(int id)? onDismissed;

  const _ListStreamSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.ref,
    required this.itemBuilder,
    this.idExtractor,
    this.onDismissed,
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
              children: list.map((item) {
                final tile = Padding(
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
                );

                if (idExtractor != null && onDismissed != null) {
                  final id = idExtractor!(item);
                  return Dismissible(
                    key: ValueKey(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red.shade900,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => onDismissed!(id),
                    child: tile,
                  );
                }
                return tile;
              }).toList(),
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
