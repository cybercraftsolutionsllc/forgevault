import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

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
import '../../core/database/schemas/health_profile.dart';
import '../../core/database/schemas/custom_ledger_section.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CRUD Helpers â€” read-mutate-write for singleton Isar ledgers
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

Future<void> _addToIdentityList(
  String value,
  void Function(CoreIdentity) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var id = await db.coreIdentitys.where().findFirst();
    id ??= CoreIdentity();
    mutator(id);
    await db.coreIdentitys.put(id);
  });
}

Future<void> _addToCareer(
  String value,
  void Function(CareerLedger) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var c = await db.careerLedgers.where().findFirst();
    c ??= CareerLedger();
    mutator(c);
    await db.careerLedgers.put(c);
  });
}

Future<void> _addToMedical(
  String value,
  void Function(MedicalLedger) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var m = await db.medicalLedgers.where().findFirst();
    m ??= MedicalLedger();
    mutator(m);
    await db.medicalLedgers.put(m);
  });
}

Future<void> _addToHealth(
  String value,
  void Function(HealthProfile) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var h = await db.healthProfiles.where().findFirst();
    h ??= HealthProfile();
    mutator(h);
    await db.healthProfiles.put(h);
  });
}

Future<void> _addToAssets(
  String value,
  void Function(AssetLedger) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var a = await db.assetLedgers.where().findFirst();
    a ??= AssetLedger();
    mutator(a);
    await db.assetLedgers.put(a);
  });
}

Future<void> _addToRelationalWeb(
  String value,
  void Function(RelationalWeb) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var r = await db.relationalWebs.where().findFirst();
    r ??= RelationalWeb();
    mutator(r);
    await db.relationalWebs.put(r);
  });
}

Future<void> _addToPsyche(
  String value,
  void Function(PsycheProfile) mutator,
) async {
  final db = DatabaseService.instance.db;
  await db.writeTxn(() async {
    var p = await db.psycheProfiles.where().findFirst();
    p ??= PsycheProfile();
    mutator(p);
    await db.psycheProfiles.put(p);
  });
}

/// Bio Viewer â€” reactive accordion view of all Isar collections.
///
/// Each section streams live data from Isar via [StreamProvider]s.
/// The UI auto-updates whenever the Forge commits new records.
class BioViewerScreen extends ConsumerWidget {
  const BioViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract hidden sections from CoreIdentity for visibility gating
    final identityData = ref.watch(identityStreamProvider);
    final hiddenSections =
        identityData.whenOrNull(data: (id) => id?.hiddenSections) ?? <String>[];

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
          // â”€â”€ Header â”€â”€
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

          // â”€â”€ Identity â”€â”€
          const _IdentitySection(),

          // â”€â”€ Location History â”€â”€
          _IdentityListSection(
            ref: ref,
            icon: Icons.map_outlined,
            title: 'Location History',
            subtitle: 'Past and current cities and addresses',
            listExtractors: [
              _ListDescriptor(
                'Locations',
                (id) => id.locationHistory,
                onAdd: (v) => _addToIdentityList(v, (id) {
                  id.locationHistory = [...?id.locationHistory, v];
                }),
                onEdit: (i, v) => _addToIdentityList(v, (id) {
                  final list = [...?id.locationHistory];
                  if (i < list.length) list[i] = v;
                  id.locationHistory = list;
                }),
                onDelete: (i) => _addToIdentityList('', (id) {
                  final list = [...?id.locationHistory];
                  if (i < list.length) list.removeAt(i);
                  id.locationHistory = list;
                }),
              ),
            ],
          ),

          // â”€â”€ Family & Lineage â”€â”€
          _IdentityListSection(
            ref: ref,
            icon: Icons.account_tree_outlined,
            title: 'Family & Lineage',
            subtitle: 'Ancestry, parents, children, heritage',
            listExtractors: [
              _ListDescriptor(
                'Lineage',
                (id) => id.familyLineage,
                onAdd: (v) => _addToIdentityList(v, (id) {
                  id.familyLineage = [...?id.familyLineage, v];
                }),
                onEdit: (i, v) => _addToIdentityList(v, (id) {
                  final list = [...?id.familyLineage];
                  if (i < list.length) list[i] = v;
                  id.familyLineage = list;
                }),
                onDelete: (i) => _addToIdentityList('', (id) {
                  final list = [...?id.familyLineage];
                  if (i < list.length) list.removeAt(i);
                  id.familyLineage = list;
                }),
              ),
            ],
          ),

          // â”€â”€ Timeline â”€â”€
          if (!hiddenSections.contains('Timeline'))
            _ListStreamSection<TimelineEvent>(
              icon: Icons.timeline_outlined,
              title: 'Timeline',
              subtitle: 'Life events in chronological order',
              provider: timelineStreamProvider,
              ref: ref,
              itemBuilder: (e) {
                try {
                  final dateStr = e.eventDate
                      .toIso8601String()
                      .split('T')
                      .first;
                  return '$dateStr  ${e.title}';
                } catch (_) {
                  return '???  ${e.title}';
                }
              },
              idExtractor: (e) => e.id,
              onDismissed: (id) =>
                  DatabaseService.instance.deleteTimelineEvent(id),
              onItemEdit: (e, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  e.title = newVal;
                  await db.timelineEvents.put(e);
                });
              },
            ),

          // â”€â”€ Troubles â”€â”€
          if (!hiddenSections.contains('Troubles'))
            _ListStreamSection<Trouble>(
              icon: Icons.warning_amber_outlined,
              title: 'Troubles',
              subtitle: 'Active and resolved issues',
              provider: troublesStreamProvider,
              ref: ref,
              itemBuilder: (t) =>
                  '${t.title} â€” Severity ${t.severity}/10${t.isResolved ? ' âœ“' : ''}',
              idExtractor: (t) => t.id,
              onDismissed: (id) => DatabaseService.instance.deleteTrouble(id),
              onItemEdit: (t, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  t.title = newVal;
                  await db.troubles.put(t);
                });
              },
            ),

          // â”€â”€ Finances â”€â”€
          if (!hiddenSections.contains('Finances'))
            _ListStreamSection<FinanceRecord>(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Finances',
              subtitle: 'Assets, debts, and transactions',
              provider: financesStreamProvider,
              ref: ref,
              itemBuilder: (f) =>
                  '${f.assetOrDebtName} \u2014 \$${f.amount.toStringAsFixed(2)} (${f.isDebt ? "Debt" : "Asset"})',
              idExtractor: (f) => f.id,
              onDismissed: (id) =>
                  DatabaseService.instance.deleteFinanceRecord(id),
              onItemEdit: (f, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  f.assetOrDebtName = newVal;
                  await db.financeRecords.put(f);
                });
              },
            ),

          // â”€â”€ Relationships â”€â”€
          if (!hiddenSections.contains('Relationships'))
            _ListStreamSection<RelationshipNode>(
              icon: Icons.people_outline,
              title: 'Relationships',
              subtitle: 'People and trust levels',
              provider: relationshipsStreamProvider,
              ref: ref,
              itemBuilder: (r) =>
                  '${r.personName} \u2014 ${r.relationType} (Trust ${r.trustLevel}/10)',
              idExtractor: (r) => r.id,
              onDismissed: (id) =>
                  DatabaseService.instance.deleteRelationship(id),
              onItemEdit: (r, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  r.personName = newVal;
                  await db.relationshipNodes.put(r);
                });
              },
            ),

          // â”€â”€ Health â”€â”€
          if (!hiddenSections.contains('Health')) _HealthSection(ref: ref),

          // â”€â”€ Goals â”€â”€
          if (!hiddenSections.contains('Goals'))
            _ListStreamSection<Goal>(
              icon: Icons.flag_outlined,
              title: 'Goals',
              subtitle: 'Targets and progress tracking',
              provider: goalsStreamProvider,
              ref: ref,
              itemBuilder: (g) =>
                  '${g.title} â€” ${g.progress}%${g.isCompleted ? ' âœ“' : ''}',
              idExtractor: (g) => g.id,
              onDismissed: (id) => DatabaseService.instance.deleteGoal(id),
              onItemEdit: (g, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  g.title = newVal;
                  await db.goals.put(g);
                });
              },
            ),

          // â”€â”€ Habits & Vices â”€â”€
          if (!hiddenSections.contains('Habits & Vices'))
            _ListStreamSection<HabitVice>(
              icon: Icons.repeat_outlined,
              title: 'Habits & Vices',
              subtitle: 'Patterns and behaviors',
              provider: habitsStreamProvider,
              ref: ref,
              itemBuilder: (h) =>
                  '${h.name} (${h.isVice ? "Vice" : "Habit"}) â€” ${h.frequency}',
              idExtractor: (h) => h.id,
              onDismissed: (id) => DatabaseService.instance.deleteHabitVice(id),
              onItemEdit: (h, newVal) async {
                final db = DatabaseService.instance.db;
                await db.writeTxn(() async {
                  h.name = newVal;
                  await db.habitVices.put(h);
                });
              },
            ),

          // â”€â”€ Medical Ledger â”€â”€
          if (!hiddenSections.contains('Medical Ledger'))
            _LedgerSection<MedicalLedger>(
              ref: ref,
              icon: Icons.medical_services_outlined,
              title: 'Medical Ledger',
              subtitle: 'Surgeries, genetics, immunizations, dental',
              provider: medicalLedgerStreamProvider,
              fieldExtractors: [
                _LedgerField(
                  'Surgeries',
                  (m) => m.surgeries,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.surgeries = [...?m.surgeries, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.surgeries];
                    if (i < l.length) l[i] = v;
                    m.surgeries = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.surgeries];
                    if (i < l.length) l.removeAt(i);
                    m.surgeries = l;
                  }),
                ),
                _LedgerField(
                  'Genetics',
                  (m) => m.genetics,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.genetics = [...?m.genetics, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.genetics];
                    if (i < l.length) l[i] = v;
                    m.genetics = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.genetics];
                    if (i < l.length) l.removeAt(i);
                    m.genetics = l;
                  }),
                ),
                _LedgerField(
                  'Vital Baselines',
                  (m) => m.vitalBaselines,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.vitalBaselines = [...?m.vitalBaselines, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.vitalBaselines];
                    if (i < l.length) l[i] = v;
                    m.vitalBaselines = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.vitalBaselines];
                    if (i < l.length) l.removeAt(i);
                    m.vitalBaselines = l;
                  }),
                ),
                _LedgerField(
                  'Vision Rx',
                  (m) => m.visionRx,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.visionRx = [...?m.visionRx, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.visionRx];
                    if (i < l.length) l[i] = v;
                    m.visionRx = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.visionRx];
                    if (i < l.length) l.removeAt(i);
                    m.visionRx = l;
                  }),
                ),
                _LedgerField(
                  'Family Medical Hx',
                  (m) => m.familyMedicalHistory,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.familyMedicalHistory = [...?m.familyMedicalHistory, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.familyMedicalHistory];
                    if (i < l.length) l[i] = v;
                    m.familyMedicalHistory = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.familyMedicalHistory];
                    if (i < l.length) l.removeAt(i);
                    m.familyMedicalHistory = l;
                  }),
                ),
                _LedgerField(
                  'Bloodwork',
                  (m) => m.bloodwork,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.bloodwork = [...?m.bloodwork, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.bloodwork];
                    if (i < l.length) l[i] = v;
                    m.bloodwork = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.bloodwork];
                    if (i < l.length) l.removeAt(i);
                    m.bloodwork = l;
                  }),
                ),
                _LedgerField(
                  'Immunizations',
                  (m) => m.immunizations,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.immunizations = [...?m.immunizations, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.immunizations];
                    if (i < l.length) l[i] = v;
                    m.immunizations = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.immunizations];
                    if (i < l.length) l.removeAt(i);
                    m.immunizations = l;
                  }),
                ),
                _LedgerField(
                  'Dental History',
                  (m) => m.dentalHistory,
                  onAdd: (v) => _addToMedical(v, (m) {
                    m.dentalHistory = [...?m.dentalHistory, v];
                  }),
                  onEdit: (i, v) => _addToMedical(v, (m) {
                    final l = [...?m.dentalHistory];
                    if (i < l.length) l[i] = v;
                    m.dentalHistory = l;
                  }),
                  onDelete: (i) => _addToMedical('', (m) {
                    final l = [...?m.dentalHistory];
                    if (i < l.length) l.removeAt(i);
                    m.dentalHistory = l;
                  }),
                ),
              ],
            ),

          // â”€â”€ Career Ledger â”€â”€
          if (!hiddenSections.contains('Career Ledger'))
            _LedgerSection<CareerLedger>(
              ref: ref,
              icon: Icons.work_outline,
              title: 'Career Ledger',
              subtitle: 'Jobs, degrees, certs, skills, projects',
              provider: careerLedgerStreamProvider,
              fieldExtractors: [
                _LedgerField(
                  'Jobs',
                  (c) => c.jobs,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.jobs = [...?c.jobs, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.jobs];
                    if (i < l.length) l[i] = v;
                    c.jobs = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.jobs];
                    if (i < l.length) l.removeAt(i);
                    c.jobs = l;
                  }),
                ),
                _LedgerField(
                  'Degrees',
                  (c) => c.degrees,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.degrees = [...?c.degrees, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.degrees];
                    if (i < l.length) l[i] = v;
                    c.degrees = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.degrees];
                    if (i < l.length) l.removeAt(i);
                    c.degrees = l;
                  }),
                ),
                _LedgerField(
                  'Certifications',
                  (c) => c.certifications,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.certifications = [...?c.certifications, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.certifications];
                    if (i < l.length) l[i] = v;
                    c.certifications = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.certifications];
                    if (i < l.length) l.removeAt(i);
                    c.certifications = l;
                  }),
                ),
                _LedgerField(
                  'Clearances',
                  (c) => c.clearances,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.clearances = [...?c.clearances, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.clearances];
                    if (i < l.length) l[i] = v;
                    c.clearances = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.clearances];
                    if (i < l.length) l.removeAt(i);
                    c.clearances = l;
                  }),
                ),
                _LedgerField(
                  'Skills',
                  (c) => c.skills,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.skills = [...?c.skills, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.skills];
                    if (i < l.length) l[i] = v;
                    c.skills = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.skills];
                    if (i < l.length) l.removeAt(i);
                    c.skills = l;
                  }),
                ),
                _LedgerField(
                  'Projects',
                  (c) => c.projects,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.projects = [...?c.projects, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.projects];
                    if (i < l.length) l[i] = v;
                    c.projects = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.projects];
                    if (i < l.length) l.removeAt(i);
                    c.projects = l;
                  }),
                ),
                _LedgerField(
                  'Ventures & Board Seats',
                  (c) => c.businesses,
                  onAdd: (v) => _addToCareer(v, (c) {
                    c.businesses = [...?c.businesses, v];
                  }),
                  onEdit: (i, v) => _addToCareer(v, (c) {
                    final l = [...?c.businesses];
                    if (i < l.length) l[i] = v;
                    c.businesses = l;
                  }),
                  onDelete: (i) => _addToCareer('', (c) {
                    final l = [...?c.businesses];
                    if (i < l.length) l.removeAt(i);
                    c.businesses = l;
                  }),
                ),
              ],
            ),

          // â”€â”€ Asset Ledger â”€â”€
          if (!hiddenSections.contains('Asset Ledger'))
            _LedgerSection<AssetLedger>(
              ref: ref,
              icon: Icons.account_balance_outlined,
              title: 'Asset Ledger',
              subtitle: 'Property, vehicles, investments, insurance',
              provider: assetLedgerStreamProvider,
              fieldExtractors: [
                _LedgerField(
                  'Real Estate',
                  (a) => a.realEstate,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.realEstate = [...?a.realEstate, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.realEstate];
                    if (i < l.length) l[i] = v;
                    a.realEstate = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.realEstate];
                    if (i < l.length) l.removeAt(i);
                    a.realEstate = l;
                  }),
                ),
                _LedgerField(
                  'Vehicles',
                  (a) => a.vehicles,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.vehicles = [...?a.vehicles, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.vehicles];
                    if (i < l.length) l[i] = v;
                    a.vehicles = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.vehicles];
                    if (i < l.length) l.removeAt(i);
                    a.vehicles = l;
                  }),
                ),
                _LedgerField(
                  'Digital Assets',
                  (a) => a.digitalAssets,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.digitalAssets = [...?a.digitalAssets, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.digitalAssets];
                    if (i < l.length) l[i] = v;
                    a.digitalAssets = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.digitalAssets];
                    if (i < l.length) l.removeAt(i);
                    a.digitalAssets = l;
                  }),
                ),
                _LedgerField(
                  'Insurance',
                  (a) => a.insurance,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.insurance = [...?a.insurance, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.insurance];
                    if (i < l.length) l[i] = v;
                    a.insurance = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.insurance];
                    if (i < l.length) l.removeAt(i);
                    a.insurance = l;
                  }),
                ),
                _LedgerField(
                  'Investments',
                  (a) => a.investments,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.investments = [...?a.investments, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.investments];
                    if (i < l.length) l[i] = v;
                    a.investments = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.investments];
                    if (i < l.length) l.removeAt(i);
                    a.investments = l;
                  }),
                ),
                _LedgerField(
                  'Valuables',
                  (a) => a.valuables,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.valuables = [...?a.valuables, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.valuables];
                    if (i < l.length) l[i] = v;
                    a.valuables = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.valuables];
                    if (i < l.length) l.removeAt(i);
                    a.valuables = l;
                  }),
                ),
                _LedgerField(
                  'Equity & Stakes',
                  (a) => a.equityStakes,
                  onAdd: (v) => _addToAssets(v, (a) {
                    a.equityStakes = [...?a.equityStakes, v];
                  }),
                  onEdit: (i, v) => _addToAssets(v, (a) {
                    final l = [...?a.equityStakes];
                    if (i < l.length) l[i] = v;
                    a.equityStakes = l;
                  }),
                  onDelete: (i) => _addToAssets('', (a) {
                    final l = [...?a.equityStakes];
                    if (i < l.length) l.removeAt(i);
                    a.equityStakes = l;
                  }),
                ),
              ],
            ),

          // â”€â”€ Relational Web â”€â”€
          if (!hiddenSections.contains('Relational Web'))
            _LedgerSection<RelationalWeb>(
              ref: ref,
              icon: Icons.hub_outlined,
              title: 'Relational Web',
              subtitle: 'Family, mentors, colleagues, friends',
              provider: relationalWebStreamProvider,
              fieldExtractors: [
                _LedgerField(
                  'Family',
                  (r) => r.family,
                  onAdd: (v) => _addToRelationalWeb(v, (r) {
                    r.family = [...?r.family, v];
                  }),
                  onEdit: (i, v) => _addToRelationalWeb(v, (r) {
                    final l = [...?r.family];
                    if (i < l.length) l[i] = v;
                    r.family = l;
                  }),
                  onDelete: (i) => _addToRelationalWeb('', (r) {
                    final l = [...?r.family];
                    if (i < l.length) l.removeAt(i);
                    r.family = l;
                  }),
                ),
                _LedgerField(
                  'Mentors',
                  (r) => r.mentors,
                  onAdd: (v) => _addToRelationalWeb(v, (r) {
                    r.mentors = [...?r.mentors, v];
                  }),
                  onEdit: (i, v) => _addToRelationalWeb(v, (r) {
                    final l = [...?r.mentors];
                    if (i < l.length) l[i] = v;
                    r.mentors = l;
                  }),
                  onDelete: (i) => _addToRelationalWeb('', (r) {
                    final l = [...?r.mentors];
                    if (i < l.length) l.removeAt(i);
                    r.mentors = l;
                  }),
                ),
                _LedgerField(
                  'Adversaries',
                  (r) => r.adversaries,
                  onAdd: (v) => _addToRelationalWeb(v, (r) {
                    r.adversaries = [...?r.adversaries, v];
                  }),
                  onEdit: (i, v) => _addToRelationalWeb(v, (r) {
                    final l = [...?r.adversaries];
                    if (i < l.length) l[i] = v;
                    r.adversaries = l;
                  }),
                  onDelete: (i) => _addToRelationalWeb('', (r) {
                    final l = [...?r.adversaries];
                    if (i < l.length) l.removeAt(i);
                    r.adversaries = l;
                  }),
                ),
                _LedgerField(
                  'Colleagues',
                  (r) => r.colleagues,
                  onAdd: (v) => _addToRelationalWeb(v, (r) {
                    r.colleagues = [...?r.colleagues, v];
                  }),
                  onEdit: (i, v) => _addToRelationalWeb(v, (r) {
                    final l = [...?r.colleagues];
                    if (i < l.length) l[i] = v;
                    r.colleagues = l;
                  }),
                  onDelete: (i) => _addToRelationalWeb('', (r) {
                    final l = [...?r.colleagues];
                    if (i < l.length) l.removeAt(i);
                    r.colleagues = l;
                  }),
                ),
                _LedgerField(
                  'Friends',
                  (r) => r.friends,
                  onAdd: (v) => _addToRelationalWeb(v, (r) {
                    r.friends = [...?r.friends, v];
                  }),
                  onEdit: (i, v) => _addToRelationalWeb(v, (r) {
                    final l = [...?r.friends];
                    if (i < l.length) l[i] = v;
                    r.friends = l;
                  }),
                  onDelete: (i) => _addToRelationalWeb('', (r) {
                    final l = [...?r.friends];
                    if (i < l.length) l.removeAt(i);
                    r.friends = l;
                  }),
                ),
              ],
            ),

          // â”€â”€ Psyche Profile â”€â”€
          if (!hiddenSections.contains('Psyche Profile'))
            _LedgerSection<PsycheProfile>(
              ref: ref,
              icon: Icons.psychology_outlined,
              title: 'Psyche Profile',
              subtitle: 'Beliefs, personality, fears, motivations',
              provider: psycheProfileStreamProvider,
              fieldExtractors: [
                _LedgerField(
                  'Beliefs',
                  (p) => p.beliefs,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.beliefs = [...?p.beliefs, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.beliefs];
                    if (i < l.length) l[i] = v;
                    p.beliefs = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.beliefs];
                    if (i < l.length) l.removeAt(i);
                    p.beliefs = l;
                  }),
                ),
                _LedgerField(
                  'Personality',
                  (p) => p.personality,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.personality = [...?p.personality, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.personality];
                    if (i < l.length) l[i] = v;
                    p.personality = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.personality];
                    if (i < l.length) l.removeAt(i);
                    p.personality = l;
                  }),
                ),
                _LedgerField(
                  'Fears',
                  (p) => p.fears,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.fears = [...?p.fears, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.fears];
                    if (i < l.length) l[i] = v;
                    p.fears = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.fears];
                    if (i < l.length) l.removeAt(i);
                    p.fears = l;
                  }),
                ),
                _LedgerField(
                  'Motivations',
                  (p) => p.motivations,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.motivations = [...?p.motivations, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.motivations];
                    if (i < l.length) l[i] = v;
                    p.motivations = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.motivations];
                    if (i < l.length) l.removeAt(i);
                    p.motivations = l;
                  }),
                ),
                _LedgerField(
                  'Strengths',
                  (p) => p.strengths,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.strengths = [...?p.strengths, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.strengths];
                    if (i < l.length) l[i] = v;
                    p.strengths = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.strengths];
                    if (i < l.length) l.removeAt(i);
                    p.strengths = l;
                  }),
                ),
                _LedgerField(
                  'Weaknesses',
                  (p) => p.weaknesses,
                  onAdd: (v) => _addToPsyche(v, (p) {
                    p.weaknesses = [...?p.weaknesses, v];
                  }),
                  onEdit: (i, v) => _addToPsyche(v, (p) {
                    final l = [...?p.weaknesses];
                    if (i < l.length) l[i] = v;
                    p.weaknesses = l;
                  }),
                  onDelete: (i) => _addToPsyche('', (p) {
                    final l = [...?p.weaknesses];
                    if (i < l.length) l.removeAt(i);
                    p.weaknesses = l;
                  }),
                ),
              ],
              scalarExtractor: (p) {
                final parts = <String>[];
                if (p.enneagram != null && p.enneagram!.isNotEmpty) {
                  parts.add('Enneagram: ${p.enneagram}');
                }
                if (p.mbti != null && p.mbti!.isNotEmpty) {
                  parts.add('MBTI: ${p.mbti}');
                }
                return parts.isEmpty ? null : parts.join('  â€¢  ');
              },
            ),

          // â”€â”€ Custom Ledger Sections â”€â”€
          ..._buildCustomSections(ref, context),

          // â”€â”€ + Create Custom Section button â”€â”€
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                '+ Create Custom Section',
                style: GoogleFonts.inter(),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: VaultColors.phosphorGreen,
                side: BorderSide(
                  color: VaultColors.phosphorGreen.withValues(alpha: 0.5),
                ),
              ),
              onPressed: () => _showCreateSectionDialog(context),
            ),
          ),

          // â”€â”€ Manage Hidden Sections button â”€â”€
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: TextButton.icon(
              icon: const Icon(Icons.visibility_off_outlined, size: 18),
              label: Text(
                'Manage Hidden Sections',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
              ),
              onPressed: () => _showManageHiddenDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Custom Section Builder â”€â”€
  List<Widget> _buildCustomSections(WidgetRef ref, BuildContext context) {
    final customAsync = ref.watch(customLedgerSectionsProvider);
    return customAsync.when(
      data: (sections) => sections.map((section) {
        return _CustomLedgerCard(
          section: section,
          onDeleteSection: () async {
            final db = DatabaseService.instance.db;
            await db.writeTxn(() async {
              await db.customLedgerSections.delete(section.id);
            });
          },
          onAddItem: (item) async {
            final db = DatabaseService.instance.db;
            await db.writeTxn(() async {
              section.items = [...section.items, item];
              section.lastUpdated = DateTime.now();
              await db.customLedgerSections.put(section);
            });
          },
          onEditItem: (index, item) async {
            final db = DatabaseService.instance.db;
            await db.writeTxn(() async {
              final items = [...section.items];
              if (index < items.length) items[index] = item;
              section.items = items;
              section.lastUpdated = DateTime.now();
              await db.customLedgerSections.put(section);
            });
          },
          onDeleteItem: (index) async {
            final db = DatabaseService.instance.db;
            await db.writeTxn(() async {
              final items = [...section.items];
              if (index < items.length) items.removeAt(index);
              section.items = items;
              section.lastUpdated = DateTime.now();
              await db.customLedgerSections.put(section);
            });
          },
        );
      }).toList(),
      loading: () => [],
      error: (_, _) => [],
    );
  }

  // â”€â”€ Create Custom Section Dialog â”€â”€
  void _showCreateSectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        title: Text(
          'Create Custom Section',
          style: GoogleFonts.inter(color: VaultColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: VaultColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Section title (e.g., Hobbies, Vehicles)',
            hintStyle: GoogleFonts.inter(color: VaultColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: VaultColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: VaultColors.phosphorGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              final db = DatabaseService.instance.db;
              await db.writeTxn(() async {
                await db.customLedgerSections.put(
                  CustomLedgerSection()
                    ..title = title
                    ..items = []
                    ..lastUpdated = DateTime.now(),
                );
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: VaultColors.primary),
            child: Text('Create', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Manage Hidden Sections Dialog â”€â”€
  void _showManageHiddenDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (ctx) => _HiddenSectionsDialog());
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Identity Section â€” Seamless Inline Property Sheet
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _IdentitySection extends ConsumerStatefulWidget {
  const _IdentitySection();

  @override
  ConsumerState<_IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends ConsumerState<_IdentitySection> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _traitsCtrl = TextEditingController();

  Timer? _saveTimer;
  int? _loadedId;

  @override
  void dispose() {
    _saveTimer?.cancel();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _dobCtrl.dispose();
    _traitsCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Sync controllers from stream data (one-time per identity) â”€â”€
  void _syncControllers(CoreIdentity identity) {
    if (_loadedId == identity.id) return;
    _loadedId = identity.id;
    _nameCtrl.text = identity.fullName;
    _locationCtrl.text = identity.location;
    _dobCtrl.text =
        identity.dateOfBirth?.toIso8601String().split('T').first ?? '';
    _traitsCtrl.text = identity.immutableTraits?.join('\n') ?? '';
  }

  // â”€â”€ Auto-create identity record if null â”€â”€
  Future<void> _ensureIdentity() async {
    final db = DatabaseService.instance.db;
    final existing = await db.coreIdentitys.where().findFirst();
    if (existing != null) return;
    final identity = CoreIdentity()
      ..fullName = ''
      ..location = ''
      ..lastUpdated = DateTime.now();
    await db.writeTxn(() async => db.coreIdentitys.put(identity));
  }

  // â”€â”€ Debounced auto-save â”€â”€
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _persistNow);
  }

  Future<void> _persistNow() async {
    final db = DatabaseService.instance.db;
    var identity = await db.coreIdentitys.where().findFirst();
    if (identity == null) {
      await _ensureIdentity();
      identity = await db.coreIdentitys.where().findFirst();
      if (identity == null) return;
    }

    identity.fullName = _nameCtrl.text.trim();
    identity.location = _locationCtrl.text.trim();

    // Parse DOB
    final dobText = _dobCtrl.text.trim();
    if (dobText.isNotEmpty) {
      try {
        identity.dateOfBirth = DateTime.parse(dobText);
      } catch (_) {
        // leave unchanged on parse error
      }
    } else {
      identity.dateOfBirth = null;
    }

    // Multi-line list fields
    identity.immutableTraits = _parseLines(_traitsCtrl.text);

    identity.lastUpdated = DateTime.now();

    // Compute completeness (4 core fields → 100%)
    int score = 0;
    if (identity.fullName.isNotEmpty) score += 30;
    if (identity.location.isNotEmpty) score += 25;
    if (identity.dateOfBirth != null) score += 25;
    if (identity.immutableTraits?.isNotEmpty == true) score += 20;
    identity.completenessScore = score;

    await db.writeTxn(() async => db.coreIdentitys.put(identity!));
  }

  List<String>? _parseLines(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.isEmpty ? null : lines;
  }

  @override
  Widget build(BuildContext context) {
    final identityAsync = ref.watch(identityStreamProvider);

    return _BioAccordion(
      icon: Icons.person_outline,
      title: 'Identity',
      subtitle: 'Core Profile (Tap to edit)',
      children: [
        identityAsync.when(
          loading: () => _loadingTile(),
          error: (e, _) => _errorTile(e),
          data: (identity) {
            if (identity == null) {
              // Auto-create on first render
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _ensureIdentity();
              });
              return _loadingTile();
            }
            _syncControllers(identity);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inlineField(
                    icon: Icons.badge_outlined,
                    label: 'Full Name',
                    controller: _nameCtrl,
                    hint: 'Enter your name',
                  ),
                  _inlineField(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    controller: _locationCtrl,
                    hint: 'City, Country',
                  ),
                  _inlineField(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    controller: _dobCtrl,
                    hint: 'YYYY-MM-DD',
                  ),
                  _inlineMultiField(
                    icon: Icons.fingerprint,
                    label: 'Traits',
                    controller: _traitsCtrl,
                    hint: 'One trait per line',
                  ),
                  // â”€â”€ Completeness indicator â”€â”€
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 14,
                        color: VaultColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completeness: ${identity.completenessScore}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: VaultColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: identity.completenessScore / 100,
                          backgroundColor: VaultColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            identity.completenessScore >= 80
                                ? VaultColors.phosphorGreen
                                : identity.completenessScore >= 50
                                ? const Color(0xFFFFD600)
                                : VaultColors.destructiveLight,
                          ),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // â”€â”€ Single-line inline field (Notion-style) â”€â”€
  Widget _inlineField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: VaultColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VaultColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: (_) => _scheduleSave(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: VaultColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: VaultColors.textMuted.withValues(alpha: 0.4),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: VaultColors.phosphorGreen.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Multi-line inline field â”€â”€
  Widget _inlineMultiField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: VaultColors.textMuted),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: VaultColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: TextFormField(
              controller: controller,
              maxLines: null,
              minLines: 1,
              onChanged: (_) => _scheduleSave(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VaultColors.textPrimary,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: VaultColors.textMuted.withValues(alpha: 0.4),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: VaultColors.phosphorGreen.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Health Section (single record)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                  // â”€â”€ Conditions â”€â”€
                  if ((hp.conditions ?? []).isNotEmpty) ...[
                    _sectionLabel('Conditions'),
                    ...hp.conditions!.asMap().entries.map(
                      (e) => _CrudItemRow(
                        value: e.value,
                        onEdit: (v) => _addToHealth(v, (h) {
                          final l = [...?h.conditions];
                          l[e.key] = v;
                          h.conditions = l;
                        }),
                        onDelete: () => _addToHealth('', (h) {
                          final l = [...?h.conditions];
                          l.removeAt(e.key);
                          h.conditions = l;
                        }),
                      ),
                    ),
                  ],
                  // â”€â”€ Medications â”€â”€
                  if ((hp.medications ?? []).isNotEmpty) ...[
                    _sectionLabel('Medications'),
                    ...hp.medications!.asMap().entries.map(
                      (e) => _CrudItemRow(
                        value: e.value,
                        onEdit: (v) => _addToHealth(v, (h) {
                          final l = [...?h.medications];
                          l[e.key] = v;
                          h.medications = l;
                        }),
                        onDelete: () => _addToHealth('', (h) {
                          final l = [...?h.medications];
                          l.removeAt(e.key);
                          h.medications = l;
                        }),
                      ),
                    ),
                  ],
                  // â”€â”€ Allergies â”€â”€
                  if ((hp.allergies ?? []).isNotEmpty) ...[
                    _sectionLabel('Allergies'),
                    ...hp.allergies!.asMap().entries.map(
                      (e) => _CrudItemRow(
                        value: e.value,
                        onEdit: (v) => _addToHealth(v, (h) {
                          final l = [...?h.allergies];
                          l[e.key] = v;
                          h.allergies = l;
                        }),
                        onDelete: () => _addToHealth('', (h) {
                          final l = [...?h.allergies];
                          l.removeAt(e.key);
                          h.allergies = l;
                        }),
                      ),
                    ),
                  ],
                  // â”€â”€ Scalar fields â”€â”€
                  _dataRow('Blood Type', hp.bloodType ?? '\u2014'),
                  if (hp.primaryPhysician != null)
                    _dataRow('Physician', hp.primaryPhysician!),
                  // â”€â”€ Lab Results â”€â”€
                  if ((hp.labResults ?? []).isNotEmpty) ...[
                    _sectionLabel('Lab Results'),
                    ...hp.labResults!.asMap().entries.map(
                      (e) => _CrudItemRow(
                        value: e.value,
                        onEdit: (v) => _addToHealth(v, (h) {
                          final l = [...?h.labResults];
                          l[e.key] = v;
                          h.labResults = l;
                        }),
                        onDelete: () => _addToHealth('', (h) {
                          final l = [...?h.labResults];
                          l.removeAt(e.key);
                          h.labResults = l;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Generic Ledger Section (single-record stream with List<String> fields)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LedgerField<T> {
  final String label;
  final List<String>? Function(T) extractor;
  final Future<void> Function(String value)? onAdd;
  final Future<void> Function(int index, String newValue)? onEdit;
  final Future<void> Function(int index)? onDelete;
  const _LedgerField(
    this.label,
    this.extractor, {
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });
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

            // List<String> field rows â€” individual items w/ CRUD
            for (final field in fieldExtractors) {
              final list = field.extractor(record);
              if (list != null && list.isNotEmpty) {
                rows.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.label.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: VaultColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (int i = 0; i < list.length; i++)
                          _CrudItemRow(
                            value: list[i],
                            onEdit: field.onEdit != null
                                ? (newVal) => field.onEdit!(i, newVal)
                                : null,
                            onDelete: field.onDelete != null
                                ? () => field.onDelete!(i)
                                : null,
                          ),
                      ],
                    ),
                  ),
                );
              }
            }

            if (rows.isEmpty) return _emptyTile();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rows,
                  const SizedBox(height: 8),
                  // CRUD: Per-field add buttons
                  for (final field in fieldExtractors)
                    if (field.onAdd != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _AddEntryButton(
                          label: field.label,
                          onAdd: field.onAdd!,
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Identity Derived List Sections (Career, Location, Lineage, Digital)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ListDescriptor {
  final String label;
  final List<String>? Function(CoreIdentity) extractor;
  final Future<void> Function(String value)? onAdd;
  final Future<void> Function(int index, String newValue)? onEdit;
  final Future<void> Function(int index)? onDelete;
  const _ListDescriptor(
    this.label,
    this.extractor, {
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });
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
                        for (int i = 0; i < items.length; i++)
                          _CrudItemRow(
                            value: items[i],
                            onEdit: desc.onEdit != null
                                ? (newVal) => desc.onEdit!(i, newVal)
                                : null,
                            onDelete: desc.onDelete != null
                                ? () => desc.onDelete!(i)
                                : null,
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
                child: Column(
                  children: [
                    Text(
                      'No data extracted yet.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: VaultColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final desc in listExtractors)
                      if (desc.onAdd != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _AddEntryButton(
                            label: desc.label,
                            onAdd: desc.onAdd!,
                          ),
                        ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  ...widgets,
                  // CRUD: Per-list add buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        for (final desc in listExtractors)
                          if (desc.onAdd != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: _AddEntryButton(
                                label: desc.label,
                                onAdd: desc.onAdd!,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Generic List Section (streams a List<T>)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ListStreamSection<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final StreamProvider<List<T>> provider;
  final WidgetRef ref;
  final String Function(T) itemBuilder;
  final int Function(T)? idExtractor;
  final Future<void> Function(int id)? onDismissed;
  final Future<void> Function(T item, String newValue)? onItemEdit;

  const _ListStreamSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.ref,
    required this.itemBuilder,
    this.idExtractor,
    this.onDismissed,
    this.onItemEdit,
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
                final label = itemBuilder(item);

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _CrudItemRow(
                        value: label,
                        onEdit: onItemEdit != null
                            ? (newVal) => onItemEdit!(item, newVal)
                            : null,
                        onDelete: () => onDismissed!(id),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _CrudItemRow(
                    value: label,
                    onEdit: onItemEdit != null
                        ? (newVal) => onItemEdit!(item, newVal)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Shared Accordion Container
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CRUD Item Row â€” each array item with edit pencil + delete trash
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CrudItemRow extends StatefulWidget {
  final String value;
  final Future<void> Function(String newValue)? onEdit;
  final Future<void> Function()? onDelete;

  const _CrudItemRow({required this.value, this.onEdit, this.onDelete});

  @override
  State<_CrudItemRow> createState() => _CrudItemRowState();
}

class _CrudItemRowState extends State<_CrudItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _isHovered
              ? VaultColors.primaryLight.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u2022  ',
              style: TextStyle(color: VaultColors.primaryLight, fontSize: 13),
            ),
            Expanded(
              child: Text(
                widget.value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: VaultColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (widget.onEdit != null)
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: _isHovered
                        ? VaultColors.primaryLight
                        : VaultColors.textMuted.withValues(alpha: 0.4),
                  ),
                ),
              ),
            if (widget.onDelete != null)
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 15,
                    color: _isHovered
                        ? Colors.redAccent
                        : Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.cardSurface,
        title: Text(
          'Edit Entry',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: VaultColors.phosphorGreen,
          ),
        ),
        content: TextFormField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: VaultColors.textPrimary,
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Edit value...',
            hintStyle: GoogleFonts.inter(color: VaultColors.textMuted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: VaultColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: VaultColors.primaryLight),
            ),
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
          TextButton(
            onPressed: () {
              final newVal = controller.text.trim();
              if (newVal.isNotEmpty && newVal != widget.value) {
                widget.onEdit!(newVal);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: VaultColors.phosphorGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.cardSurface,
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        content: Text(
          '"${widget.value}"',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: VaultColors.textSecondary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete!();
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Add Entry Button â€” opens a dialog for manual CRUD
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AddEntryButton extends StatelessWidget {
  final String label;
  final Future<void> Function(String value) onAdd;

  const _AddEntryButton({required this.label, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(Icons.add, size: 14, color: VaultColors.primaryLight),
        label: Text(
          '+ Add $label',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: VaultColors.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: VaultColors.primaryLight.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 6),
        ),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Text(
          'Add $label',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: VaultColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: VaultColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Enter new $label entry...',
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: VaultColors.textMuted,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: VaultColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: VaultColors.primaryLight),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await onAdd(value);
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: VaultColors.primaryLight,
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
}

// â”€â”€ Shared Utility Widgets â”€â”€

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

Widget _sectionLabel(String label) => Padding(
  padding: const EdgeInsets.only(top: 10, bottom: 4, left: 4),
  child: Text(
    label.toUpperCase(),
    style: GoogleFonts.jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: VaultColors.primaryLight,
      letterSpacing: 1.5,
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
          value.isEmpty ? 'â€”' : value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: VaultColors.textPrimary,
          ),
        ),
      ),
    ],
  ),
);

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Custom Ledger Card â€” renders a user-created section
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CustomLedgerCard extends StatelessWidget {
  final CustomLedgerSection section;
  final VoidCallback onDeleteSection;
  final Future<void> Function(CustomItem item) onAddItem;
  final Future<void> Function(int index, CustomItem item) onEditItem;
  final Future<void> Function(int index) onDeleteItem;

  const _CustomLedgerCard({
    required this.section,
    required this.onDeleteSection,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: VaultColors.cardSurface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: VaultColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and delete button
            Row(
              children: [
                Icon(
                  Icons.folder_special_outlined,
                  color: VaultColors.phosphorGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: VaultColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: VaultColors.destructiveLight,
                    size: 20,
                  ),
                  tooltip: 'Delete Section',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: VaultColors.surface,
                        title: Text(
                          'Delete "${section.title}"?',
                          style: GoogleFonts.inter(
                            color: VaultColors.textPrimary,
                          ),
                        ),
                        content: Text(
                          'This will permanently remove this section and all its items.',
                          style: GoogleFonts.inter(
                            color: VaultColors.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: VaultColors.textSecondary,
                              ),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: VaultColors.destructive,
                            ),
                            child: Text('Delete', style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) onDeleteSection();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Items â€” key/value rows
            ...section.items.asMap().entries.map((entry) {
              final item = entry.value;
              final display = (item.value?.isNotEmpty == true)
                  ? '${item.name ?? ""}: ${item.value}'
                  : item.name ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        display,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: VaultColors.textMuted,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          _showEditDialog(context, entry.key, item),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: VaultColors.destructiveLight,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => onDeleteItem(entry.key),
                    ),
                  ],
                ),
              );
            }),
            // + Add Item button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.add,
                  size: 14,
                  color: VaultColors.primaryLight,
                ),
                label: Text(
                  '+ Add Item',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: VaultColors.primaryLight,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: VaultColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => _showAddDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    final valueCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        title: Text(
          'Add Item',
          style: GoogleFonts.inter(color: VaultColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              autofocus: true,
              style: GoogleFonts.inter(color: VaultColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.inter(color: VaultColors.textMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.phosphorGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtl,
              style: GoogleFonts.inter(color: VaultColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: GoogleFonts.inter(color: VaultColors.textMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.phosphorGreen),
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
              style: GoogleFonts.inter(color: VaultColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              await onAddItem(
                CustomItem()
                  ..name = name
                  ..value = valueCtl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: VaultColors.primary),
            child: Text('Add', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, CustomItem existing) {
    final nameCtl = TextEditingController(text: existing.name ?? '');
    final valueCtl = TextEditingController(text: existing.value ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        title: Text(
          'Edit Item',
          style: GoogleFonts.inter(color: VaultColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              autofocus: true,
              style: GoogleFonts.inter(color: VaultColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.inter(color: VaultColors.textMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.phosphorGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtl,
              style: GoogleFonts.inter(color: VaultColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: GoogleFonts.inter(color: VaultColors.textMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: VaultColors.phosphorGreen),
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
              style: GoogleFonts.inter(color: VaultColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              await onEditItem(
                index,
                CustomItem()
                  ..name = name
                  ..value = valueCtl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: VaultColors.primary),
            child: Text('Save', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Hidden Sections Dialog
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HiddenSectionsDialog extends StatefulWidget {
  @override
  State<_HiddenSectionsDialog> createState() => _HiddenSectionsDialogState();
}

class _HiddenSectionsDialogState extends State<_HiddenSectionsDialog> {
  List<String> _hidden = [];

  static const _allSections = [
    'Timeline',
    'Troubles',
    'Finances',
    'Relationships',
    'Health',
    'Goals',
    'Habits & Vices',
    'Medical Ledger',
    'Career Ledger',
    'Asset Ledger',
    'Relational Web',
    'Psyche Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadHidden();
  }

  Future<void> _loadHidden() async {
    final db = DatabaseService.instance.db;
    final identity = await db.coreIdentitys.where().findFirst();
    if (identity != null && mounted) {
      setState(() => _hidden = [...identity.hiddenSections]);
    }
  }

  Future<void> _save() async {
    final db = DatabaseService.instance.db;
    await db.writeTxn(() async {
      var identity = await db.coreIdentitys.where().findFirst();
      identity ??= CoreIdentity()
        ..fullName = ''
        ..location = ''
        ..lastUpdated = DateTime.now();
      identity.hiddenSections = _hidden;
      identity.lastUpdated = DateTime.now();
      await db.coreIdentitys.put(identity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: VaultColors.surface,
      title: Text(
        'Manage Hidden Sections',
        style: GoogleFonts.inter(color: VaultColors.textPrimary),
      ),
      content: SizedBox(
        width: 300,
        child: ListView(
          shrinkWrap: true,
          children: _allSections.map((section) {
            final isHidden = _hidden.contains(section);
            return SwitchListTile(
              title: Text(
                section,
                style: GoogleFonts.inter(
                  color: isHidden
                      ? VaultColors.textMuted
                      : VaultColors.textPrimary,
                ),
              ),
              value: !isHidden,
              activeThumbColor: VaultColors.phosphorGreen,
              onChanged: (visible) {
                setState(() {
                  if (visible) {
                    _hidden.remove(section);
                  } else {
                    _hidden.add(section);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: VaultColors.textSecondary),
          ),
        ),
        FilledButton(
          onPressed: () async {
            await _save();
            if (context.mounted) Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: VaultColors.primary),
          child: Text('Save', style: GoogleFonts.inter()),
        ),
      ],
    );
  }
}
