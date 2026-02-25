import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/forge_service.dart';
import '../../theme/theme.dart';

/// Diff Review Screen — Human-in-the-loop verification.
///
/// Displays the parsed ForgeResult before committing to Isar.
/// Users can edit fields or reject the extraction entirely.
/// The "Approve & Purge Original" button requires explicit confirmation.
class SynthesisReviewScreen extends StatefulWidget {
  final ForgeResult result;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const SynthesisReviewScreen({
    super.key,
    required this.result,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<SynthesisReviewScreen> createState() => _SynthesisReviewScreenState();
}

class _SynthesisReviewScreenState extends State<SynthesisReviewScreen> {
  late ForgeResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rate_review_rounded,
              color: VaultColors.phosphorGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'REVIEW EXTRACTION',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: VaultColors.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        backgroundColor: VaultColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: VaultColors.textMuted),
          onPressed: widget.onReject,
        ),
      ),
      body: Column(
        children: [
          // Scrollable content (changelog + ledger cards)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                if (_result.changelog.isNotEmpty) _buildChangelog(),
                if (_result.identity != null) _buildIdentitySection(),
                if (_result.timelineEvents.isNotEmpty) _buildTimelineSection(),
                if (_result.troubles.isNotEmpty) _buildTroublesSection(),
                if (_result.finances.isNotEmpty) _buildFinancesSection(),
                if (_result.relationships.isNotEmpty)
                  _buildRelationshipsSection(),
                if (_result.healthProfile != null) _buildHealthSection(),
                if (_result.goals.isNotEmpty) _buildGoalsSection(),
                if (_result.habitsVices.isNotEmpty) _buildHabitsSection(),
                if (_result.medicalLedger != null) _buildMedicalSection(),
                if (_result.careerLedger != null) _buildCareerSection(),
                if (_result.assetLedger != null) _buildAssetsSection(),
                if (_result.relationalWeb != null) _buildRelationalWebSection(),
                if (_result.psycheProfile != null) _buildPsycheSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Action bar
          _buildActionBar(),
        ],
      ),
    );
  }

  // ── Contradictions Warning ──

  Widget _buildChangelog() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A2332),
        border: Border.all(color: const Color(0xFF2A3A4A), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_fix_high_rounded,
                color: Color(0xFF64B5F6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI MODIFICATION LOG',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF90CAF9),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final entry in _result.changelog)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF64B5F6))),
                  Expanded(
                    child: Text(
                      entry,
                      style: GoogleFonts.inter(
                        fontSize: 12,
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
    );
  }

  // ── Section Builders ──

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: VaultColors.primaryLight, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: VaultColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: VaultColors.phosphorGreenDim,
            ),
            child: Text(
              '$count',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VaultColors.phosphorGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            child: InkWell(
              onTap: () => _editField(label, value, onChanged),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: VaultColors.surfaceVariant,
                  border: Border.all(
                    color: VaultColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.isEmpty ? '—' : value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: value.isEmpty
                              ? VaultColors.textMuted
                              : VaultColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: VaultColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: VaultDecorations.metallicCard(borderRadius: 12),
      child: child,
    );
  }

  // ── Identity Section ──

  Widget _buildIdentitySection() {
    final id = _result.identity!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Identity', Icons.person_rounded, 1),
        _buildDataCard(
          Column(
            children: [
              _buildEditableField('Name', id.fullName, (v) {
                setState(() => id.fullName = v);
              }),
              _buildEditableField('Location', id.location, (v) {
                setState(() => id.location = v);
              }),
              _buildEditableField(
                'Born',
                id.dateOfBirth?.toIso8601String().split('T').first ?? '',
                (_) {},
              ),
              if ((id.locationHistory ?? []).isNotEmpty)
                _buildEditableField(
                  'Location History',
                  id.locationHistory!.join(', '),
                  (_) {},
                ),
              if ((id.familyLineage ?? []).isNotEmpty)
                _buildEditableField(
                  'Family Lineage',
                  id.familyLineage!.join(', '),
                  (_) {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Timeline Section ──

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Timeline Events',
          Icons.timeline_rounded,
          _result.timelineEvents.length,
        ),
        for (var i = 0; i < _result.timelineEvents.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField('Title', _result.timelineEvents[i].title, (
                  v,
                ) {
                  setState(() => _result.timelineEvents[i].title = v);
                }),
                _buildEditableField(
                  'Category',
                  _result.timelineEvents[i].category,
                  (v) {
                    setState(() => _result.timelineEvents[i].category = v);
                  },
                ),
                _buildEditableField(
                  'Date',
                  _result.timelineEvents[i].eventDate
                      .toIso8601String()
                      .split('T')
                      .first,
                  (_) {},
                ),
                _buildEditableField(
                  'Impact',
                  '${_result.timelineEvents[i].emotionalImpactScore}/10',
                  (_) {},
                ),
                _buildEditableField(
                  'Description',
                  _result.timelineEvents[i].description,
                  (v) {
                    setState(() => _result.timelineEvents[i].description = v);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Troubles Section ──

  Widget _buildTroublesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Troubles',
          Icons.warning_amber_rounded,
          _result.troubles.length,
        ),
        for (var i = 0; i < _result.troubles.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField('Title', _result.troubles[i].title, (v) {
                  setState(() => _result.troubles[i].title = v);
                }),
                _buildEditableField('Category', _result.troubles[i].category, (
                  v,
                ) {
                  setState(() => _result.troubles[i].category = v);
                }),
                _buildEditableField(
                  'Severity',
                  '${_result.troubles[i].severity}/10',
                  (_) {},
                ),
                _buildEditableField('Detail', _result.troubles[i].detailText, (
                  v,
                ) {
                  setState(() => _result.troubles[i].detailText = v);
                }),
              ],
            ),
          ),
      ],
    );
  }

  // ── Finances Section ──

  Widget _buildFinancesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Finances',
          Icons.account_balance_rounded,
          _result.finances.length,
        ),
        for (var i = 0; i < _result.finances.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField(
                  'Name',
                  _result.finances[i].assetOrDebtName,
                  (v) {
                    setState(() => _result.finances[i].assetOrDebtName = v);
                  },
                ),
                _buildEditableField(
                  'Amount',
                  '\$${_result.finances[i].amount.toStringAsFixed(2)}',
                  (_) {},
                ),
                _buildEditableField(
                  'Type',
                  _result.finances[i].isDebt ? 'Debt' : 'Asset',
                  (_) {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Relationships Section ──

  Widget _buildRelationshipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Relationships',
          Icons.people_rounded,
          _result.relationships.length,
        ),
        for (var i = 0; i < _result.relationships.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField(
                  'Name',
                  _result.relationships[i].personName,
                  (v) {
                    setState(() => _result.relationships[i].personName = v);
                  },
                ),
                _buildEditableField(
                  'Relation',
                  _result.relationships[i].relationType,
                  (v) {
                    setState(() => _result.relationships[i].relationType = v);
                  },
                ),
                _buildEditableField(
                  'Trust',
                  '${_result.relationships[i].trustLevel}/10',
                  (_) {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Health Section ──

  Widget _buildHealthSection() {
    final hp = _result.healthProfile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Health', Icons.favorite_rounded, 1),
        _buildDataCard(
          Column(
            children: [
              _buildEditableField(
                'Conditions',
                (hp.conditions ?? []).join(', '),
                (_) {},
              ),
              _buildEditableField(
                'Medications',
                (hp.medications ?? []).join(', '),
                (_) {},
              ),
              _buildEditableField(
                'Allergies',
                (hp.allergies ?? []).join(', '),
                (_) {},
              ),
              _buildEditableField('Blood Type', hp.bloodType ?? '—', (_) {}),
              if ((hp.labResults ?? []).isNotEmpty)
                _buildEditableField(
                  'Lab Results',
                  hp.labResults!.join(', '),
                  (_) {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Goals Section ──

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Goals', Icons.flag_rounded, _result.goals.length),
        for (var i = 0; i < _result.goals.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField('Title', _result.goals[i].title, (v) {
                  setState(() => _result.goals[i].title = v);
                }),
                _buildEditableField('Category', _result.goals[i].category, (v) {
                  setState(() => _result.goals[i].category = v);
                }),
                _buildEditableField(
                  'Progress',
                  '${_result.goals[i].progress}%',
                  (_) {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Habits/Vices Section ──

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Habits & Vices',
          Icons.loop_rounded,
          _result.habitsVices.length,
        ),
        for (var i = 0; i < _result.habitsVices.length; i++)
          _buildDataCard(
            Column(
              children: [
                _buildEditableField('Name', _result.habitsVices[i].name, (v) {
                  setState(() => _result.habitsVices[i].name = v);
                }),
                _buildEditableField(
                  'Type',
                  _result.habitsVices[i].isVice ? 'Vice' : 'Habit',
                  (_) {},
                ),
                _buildEditableField(
                  'Frequency',
                  _result.habitsVices[i].frequency,
                  (_) {},
                ),
                _buildEditableField(
                  'Severity',
                  '${_result.habitsVices[i].severity}/10',
                  (_) {},
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Medical Ledger Section ──

  Widget _buildMedicalSection() {
    final m = _result.medicalLedger!;
    final entries = <MapEntry<String, List<String>?>>[
      MapEntry('Surgeries', m.surgeries),
      MapEntry('Genetics', m.genetics),
      MapEntry('Vital Baselines', m.vitalBaselines),
      MapEntry('Vision Rx', m.visionRx),
      MapEntry('Family Medical Hx', m.familyMedicalHistory),
      MapEntry('Bloodwork', m.bloodwork),
      MapEntry('Immunizations', m.immunizations),
      MapEntry('Dental History', m.dentalHistory),
    ];
    final populated = entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    if (populated.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Medical Ledger',
          Icons.medical_services_rounded,
          populated.length,
        ),
        _buildDataCard(
          Column(
            children: populated
                .map(
                  (e) =>
                      _buildEditableField(e.key, e.value!.join(', '), (_) {}),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Career Ledger Section ──

  Widget _buildCareerSection() {
    final c = _result.careerLedger!;
    final entries = <MapEntry<String, List<String>?>>[
      MapEntry('Jobs', c.jobs),
      MapEntry('Degrees', c.degrees),
      MapEntry('Certifications', c.certifications),
      MapEntry('Clearances', c.clearances),
      MapEntry('Skills', c.skills),
      MapEntry('Projects', c.projects),
    ];
    final populated = entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    if (populated.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Career Ledger',
          Icons.work_rounded,
          populated.length,
        ),
        _buildDataCard(
          Column(
            children: populated
                .map(
                  (e) =>
                      _buildEditableField(e.key, e.value!.join(', '), (_) {}),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Assets Ledger Section ──

  Widget _buildAssetsSection() {
    final a = _result.assetLedger!;
    final entries = <MapEntry<String, List<String>?>>[
      MapEntry('Real Estate', a.realEstate),
      MapEntry('Vehicles', a.vehicles),
      MapEntry('Digital Assets', a.digitalAssets),
      MapEntry('Insurance', a.insurance),
      MapEntry('Investments', a.investments),
      MapEntry('Valuables', a.valuables),
    ];
    final populated = entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    if (populated.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Asset Ledger',
          Icons.account_balance_rounded,
          populated.length,
        ),
        _buildDataCard(
          Column(
            children: populated
                .map(
                  (e) =>
                      _buildEditableField(e.key, e.value!.join(', '), (_) {}),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Relational Web Section ──

  Widget _buildRelationalWebSection() {
    final r = _result.relationalWeb!;
    final entries = <MapEntry<String, List<String>?>>[
      MapEntry('Family', r.family),
      MapEntry('Mentors', r.mentors),
      MapEntry('Adversaries', r.adversaries),
      MapEntry('Colleagues', r.colleagues),
      MapEntry('Friends', r.friends),
    ];
    final populated = entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    if (populated.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Relational Web',
          Icons.hub_rounded,
          populated.length,
        ),
        _buildDataCard(
          Column(
            children: populated
                .map(
                  (e) =>
                      _buildEditableField(e.key, e.value!.join(', '), (_) {}),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Psyche Profile Section ──

  Widget _buildPsycheSection() {
    final p = _result.psycheProfile!;
    final listEntries = <MapEntry<String, List<String>?>>[
      MapEntry('Beliefs', p.beliefs),
      MapEntry('Personality', p.personality),
      MapEntry('Fears', p.fears),
      MapEntry('Motivations', p.motivations),
      MapEntry('Strengths', p.strengths),
      MapEntry('Weaknesses', p.weaknesses),
    ];
    final populated = listEntries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    final hasScalars =
        (p.enneagram != null && p.enneagram!.isNotEmpty) ||
        (p.mbti != null && p.mbti!.isNotEmpty);
    if (populated.isEmpty && !hasScalars) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Psyche Profile',
          Icons.psychology_rounded,
          populated.length + (hasScalars ? 1 : 0),
        ),
        _buildDataCard(
          Column(
            children: [
              if (p.enneagram != null && p.enneagram!.isNotEmpty)
                _buildEditableField('Enneagram', p.enneagram!, (_) {}),
              if (p.mbti != null && p.mbti!.isNotEmpty)
                _buildEditableField('MBTI', p.mbti!, (_) {}),
              ...populated.map(
                (e) => _buildEditableField(e.key, e.value!.join(', '), (_) {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Action Bar ──

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        border: Border(top: BorderSide(color: VaultColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Reject button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onReject,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(
                'Reject',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: VaultColors.textSecondary,
                side: const BorderSide(color: VaultColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Approve & Purge button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _confirmAndApprove,
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: Text(
                'Approve & Purge Original',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.destructive,
                foregroundColor: VaultColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ──

  Future<void> _confirmAndApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: VaultColors.destructiveLight,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Irreversible Action',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: VaultColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'This will commit the extracted data to your encrypted database '
          'and cryptographically destroy the original file.\n\n'
          'This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: VaultColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: VaultColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.destructive,
              foregroundColor: VaultColors.textPrimary,
            ),
            child: Text(
              'PURGE ORIGINAL',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onApprove();

      // Show green confirmation SnackBar and safely pop back.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vault Updated ✓',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: VaultColors.phosphorGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _editField(
    String label,
    String currentValue,
    ValueChanged<String> onChanged,
  ) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit $label',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: VaultColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: label == 'Description' || label == 'Detail' ? 4 : 1,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: VaultColors.textPrimary,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: VaultColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: VaultColors.phosphorGreenDim,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              foregroundColor: VaultColors.textPrimary,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      onChanged(result);
    }
    controller.dispose();
  }
}
