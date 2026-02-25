import 'dart:convert';

import 'package:isar/isar.dart';

import '../database/schemas/core_identity.dart';
import '../database/schemas/finance_record.dart';
import '../database/schemas/goal.dart';
import '../database/schemas/habit_vice.dart';
import '../database/schemas/health_profile.dart';
import '../database/schemas/relationship_node.dart';
import '../database/schemas/timeline_event.dart';
import '../database/schemas/trouble.dart';
import '../database/schemas/career_ledger.dart';
import '../database/schemas/medical_ledger.dart';
import '../database/schemas/asset_ledger.dart';
import '../database/schemas/relational_web.dart';
import '../database/schemas/psyche_profile.dart';
import '../database/schemas/custom_ledger_section.dart';

/// Local RAG Engine — queries the encrypted Isar vault to build
/// dense, token-efficient context blobs for LLM consumption.
///
/// All queries are on-device. Data never leaves the device until
/// the user explicitly approves via the Airlock Interceptor.
class LocalRagService {
  final Isar _isar;

  LocalRagService(this._isar);

  // ── Blueprint-Specific Category Presets ──

  /// Career + Education events for resume generation.
  static const resumeCategories = ['Career', 'Education', 'Professional'];

  /// Health + Troubles + Relationships for therapist prep.
  static const therapistCategories = [
    'Health',
    'Relationship',
    'Mental Health',
  ];

  /// All categories for general RAG context.
  static const allCategories = <String>[];

  // ─────────────────────────────────────────────────────────────
  // Core Builder
  // ─────────────────────────────────────────────────────────────

  /// Build a dense, token-efficient JSON context blob from the Isar vault.
  ///
  /// [categories] — filter TimelineEvents, Troubles, and Goals by category.
  ///   Pass an empty list for unfiltered (all records).
  /// [includeIdentity] — prepend CoreIdentity data if available.
  /// [includeHealth] — include HealthProfile data (for therapist/clinical).
  /// [includeRelationships] — include RelationshipNode data.
  /// [includeFinances] — include FinanceRecord data.
  /// [includeHabits] — include HabitVice data.
  /// [maxTimelineEvents] — cap on timeline events to keep token budget tight.
  /// [maxTroubles] — cap on troubles.
  /// [maxGoals] — cap on goals.
  Future<String> buildContextBlob({
    required List<String> categories,
    bool includeIdentity = true,
    bool includeHealth = false,
    bool includeRelationships = false,
    bool includeFinances = false,
    bool includeHabits = false,
    int maxTimelineEvents = 25,
    int maxTroubles = 15,
    int maxGoals = 10,
  }) async {
    final blob = <String, dynamic>{};
    final filterByCategory = categories.isNotEmpty;

    // ── Identity ──
    if (includeIdentity) {
      final identity = await _isar.coreIdentitys.where().findFirst();
      if (identity != null) {
        final idData = <String, dynamic>{};
        if (identity.fullName.isNotEmpty) {
          idData['name'] = identity.fullName;
        }
        if (identity.location.isNotEmpty) {
          idData['location'] = identity.location;
        }
        if (identity.dateOfBirth != null) {
          idData['dob'] = identity.dateOfBirth!
              .toIso8601String()
              .split('T')
              .first;
        }
        if ((identity.immutableTraits ?? []).isNotEmpty) {
          idData['traits'] = identity.immutableTraits;
        }
        if ((identity.locationHistory ?? []).isNotEmpty) {
          idData['locationHistory'] = identity.locationHistory;
        }
        if ((identity.familyLineage ?? []).isNotEmpty) {
          idData['familyLineage'] = identity.familyLineage;
        }
        if (idData.isNotEmpty) {
          blob['identity'] = idData;
        }
      }
    }

    // ── Timeline Events ──
    List<TimelineEvent> events;
    if (filterByCategory) {
      events = await _isar.timelineEvents
          .filter()
          .anyOf(categories, (q, cat) => q.categoryEqualTo(cat))
          .sortByEventDateDesc()
          .limit(maxTimelineEvents)
          .findAll();
    } else {
      events = await _isar.timelineEvents
          .where()
          .sortByEventDateDesc()
          .limit(maxTimelineEvents)
          .findAll();
    }
    if (events.isNotEmpty) {
      blob['timeline'] = events
          .map(
            (e) => {
              'date': e.eventDate.toIso8601String().split('T').first,
              'title': e.title,
              'desc': e.description,
              'cat': e.category,
              'impact': e.emotionalImpactScore,
            },
          )
          .toList();
    }

    // ── Troubles ──
    List<Trouble> troubles;
    if (filterByCategory) {
      troubles = await _isar.troubles
          .filter()
          .anyOf(categories, (q, cat) => q.categoryEqualTo(cat))
          .sortBySeverityDesc()
          .limit(maxTroubles)
          .findAll();
    } else {
      troubles = await _isar.troubles
          .where()
          .sortBySeverityDesc()
          .limit(maxTroubles)
          .findAll();
    }
    if (troubles.isNotEmpty) {
      blob['troubles'] = troubles
          .map(
            (t) => {
              'title': t.title,
              'detail': t.detailText,
              'cat': t.category,
              'severity': t.severity,
              'resolved': t.isResolved,
            },
          )
          .toList();
    }

    // ── Goals ──
    List<Goal> goals;
    if (filterByCategory) {
      goals = await _isar.goals
          .filter()
          .anyOf(categories, (q, cat) => q.categoryEqualTo(cat))
          .sortByProgress()
          .limit(maxGoals)
          .findAll();
    } else {
      goals = await _isar.goals
          .where()
          .sortByProgress()
          .limit(maxGoals)
          .findAll();
    }
    if (goals.isNotEmpty) {
      blob['goals'] = goals
          .map(
            (g) => {
              'title': g.title,
              'cat': g.category,
              'desc': g.description,
              'target': g.targetDate?.toIso8601String().split('T').first,
              'progress': g.progress,
              'done': g.isCompleted,
            },
          )
          .toList();
    }

    // ── Finances ──
    if (includeFinances) {
      final finances = await _isar.financeRecords.where().findAll();
      if (finances.isNotEmpty) {
        blob['finances'] = finances
            .map(
              (f) => {
                'name': f.assetOrDebtName,
                'amount': f.amount,
                'debt': f.isDebt,
                'notes': f.notes,
              },
            )
            .toList();
      }
    }

    // ── Health ──
    if (includeHealth) {
      final hp = await _isar.healthProfiles.where().findFirst();
      if (hp != null) {
        blob['health'] = {
          'conditions': hp.conditions,
          'medications': hp.medications,
          'allergies': hp.allergies,
          'bloodType': hp.bloodType,
          'physician': hp.primaryPhysician,
          'insurance': hp.insuranceInfo,
        };
      }
    }

    // ── Relationships ──
    if (includeRelationships) {
      final rels = await _isar.relationshipNodes.where().findAll();
      if (rels.isNotEmpty) {
        blob['relationships'] = rels
            .map(
              (r) => {
                'name': r.personName,
                'type': r.relationType,
                'trust': r.trustLevel,
                'recent': r.recentConflictOrSupport,
              },
            )
            .toList();
      }
    }

    // ── Habits / Vices ──
    if (includeHabits) {
      final habits = await _isar.habitVices.where().findAll();
      if (habits.isNotEmpty) {
        blob['habits'] = habits
            .map(
              (h) => {
                'name': h.name,
                'vice': h.isVice,
                'freq': h.frequency,
                'severity': h.severity,
              },
            )
            .toList();
      }
    }

    // ── Career Ledger (always included — critical for all queries) ──
    final career = await _isar.careerLedgers.where().findFirst();
    if (career != null) {
      final careerData = <String, dynamic>{};
      if ((career.jobs ?? []).isNotEmpty) {
        careerData['jobs'] = career.jobs;
      }
      if ((career.degrees ?? []).isNotEmpty) {
        careerData['degrees'] = career.degrees;
      }
      if ((career.certifications ?? []).isNotEmpty) {
        careerData['certifications'] = career.certifications;
      }
      if ((career.clearances ?? []).isNotEmpty) {
        careerData['clearances'] = career.clearances;
      }
      if ((career.skills ?? []).isNotEmpty) {
        careerData['skills'] = career.skills;
      }
      if ((career.projects ?? []).isNotEmpty) {
        careerData['projects'] = career.projects;
      }
      if ((career.businesses ?? []).isNotEmpty) {
        careerData['businesses'] = career.businesses;
      }
      if (careerData.isNotEmpty) {
        blob['career'] = careerData;
      }
    }

    // ── Medical Ledger ──
    final medical = await _isar.medicalLedgers.where().findFirst();
    if (medical != null) {
      final medData = <String, dynamic>{};
      if ((medical.surgeries ?? []).isNotEmpty) {
        medData['surgeries'] = medical.surgeries;
      }
      if ((medical.genetics ?? []).isNotEmpty) {
        medData['genetics'] = medical.genetics;
      }
      if ((medical.vitalBaselines ?? []).isNotEmpty) {
        medData['vitalBaselines'] = medical.vitalBaselines;
      }
      if ((medical.visionRx ?? []).isNotEmpty) {
        medData['visionRx'] = medical.visionRx;
      }
      if ((medical.familyMedicalHistory ?? []).isNotEmpty) {
        medData['familyMedicalHistory'] = medical.familyMedicalHistory;
      }
      if ((medical.bloodwork ?? []).isNotEmpty) {
        medData['bloodwork'] = medical.bloodwork;
      }
      if ((medical.immunizations ?? []).isNotEmpty) {
        medData['immunizations'] = medical.immunizations;
      }
      if ((medical.dentalHistory ?? []).isNotEmpty) {
        medData['dentalHistory'] = medical.dentalHistory;
      }
      if (medData.isNotEmpty) {
        blob['medical'] = medData;
      }
    }

    // ── Asset Ledger ──
    final assets = await _isar.assetLedgers.where().findFirst();
    if (assets != null) {
      final assetData = <String, dynamic>{};
      if ((assets.realEstate ?? []).isNotEmpty) {
        assetData['realEstate'] = assets.realEstate;
      }
      if ((assets.vehicles ?? []).isNotEmpty) {
        assetData['vehicles'] = assets.vehicles;
      }
      if ((assets.digitalAssets ?? []).isNotEmpty) {
        assetData['digitalAssets'] = assets.digitalAssets;
      }
      if ((assets.insurance ?? []).isNotEmpty) {
        assetData['insurance'] = assets.insurance;
      }
      if ((assets.investments ?? []).isNotEmpty) {
        assetData['investments'] = assets.investments;
      }
      if ((assets.valuables ?? []).isNotEmpty) {
        assetData['valuables'] = assets.valuables;
      }
      if ((assets.equityStakes ?? []).isNotEmpty) {
        assetData['equityStakes'] = assets.equityStakes;
      }
      if (assetData.isNotEmpty) {
        blob['assets'] = assetData;
      }
    }

    // ── Relational Web ──
    final relWeb = await _isar.relationalWebs.where().findFirst();
    if (relWeb != null) {
      final rwData = <String, dynamic>{};
      if ((relWeb.family ?? []).isNotEmpty) {
        rwData['family'] = relWeb.family;
      }
      if ((relWeb.mentors ?? []).isNotEmpty) {
        rwData['mentors'] = relWeb.mentors;
      }
      if ((relWeb.adversaries ?? []).isNotEmpty) {
        rwData['adversaries'] = relWeb.adversaries;
      }
      if ((relWeb.colleagues ?? []).isNotEmpty) {
        rwData['colleagues'] = relWeb.colleagues;
      }
      if ((relWeb.friends ?? []).isNotEmpty) {
        rwData['friends'] = relWeb.friends;
      }
      if (rwData.isNotEmpty) {
        blob['relationalWeb'] = rwData;
      }
    }

    // ── Psyche Profile ──
    final psyche = await _isar.psycheProfiles.where().findFirst();
    if (psyche != null) {
      final psyData = <String, dynamic>{};
      if (psyche.mbti != null && psyche.mbti!.isNotEmpty) {
        psyData['mbti'] = psyche.mbti;
      }
      if (psyche.enneagram != null && psyche.enneagram!.isNotEmpty) {
        psyData['enneagram'] = psyche.enneagram;
      }
      if ((psyche.beliefs ?? []).isNotEmpty) {
        psyData['beliefs'] = psyche.beliefs;
      }
      if ((psyche.personality ?? []).isNotEmpty) {
        psyData['personality'] = psyche.personality;
      }
      if ((psyche.fears ?? []).isNotEmpty) {
        psyData['fears'] = psyche.fears;
      }
      if ((psyche.motivations ?? []).isNotEmpty) {
        psyData['motivations'] = psyche.motivations;
      }
      if ((psyche.strengths ?? []).isNotEmpty) {
        psyData['strengths'] = psyche.strengths;
      }
      if ((psyche.weaknesses ?? []).isNotEmpty) {
        psyData['weaknesses'] = psyche.weaknesses;
      }
      if (psyData.isNotEmpty) {
        blob['psyche'] = psyData;
      }
    }

    // ── Custom Ledger Sections ──
    final customSections = await _isar.customLedgerSections.where().findAll();
    if (customSections.isNotEmpty) {
      final customData = <String, dynamic>{};
      for (final section in customSections) {
        if (section.items.isNotEmpty) {
          customData[section.title] = section.items
              .map((i) => {'name': i.name ?? '', 'value': i.value ?? ''})
              .toList();
        }
      }
      if (customData.isNotEmpty) {
        blob['customLedgers'] = customData;
      }
    }

    // ── Hidden Section Filtering ──
    // Remove any default sections the user has hidden
    final identity = await _isar.coreIdentitys.where().findFirst();
    if (identity != null && identity.hiddenSections.isNotEmpty) {
      // Map display titles to blob keys
      const titleToKey = {
        'Timeline': 'timeline',
        'Troubles': 'troubles',
        'Finances': 'finances',
        'Relationships': 'relationships',
        'Health': 'health',
        'Goals': 'goals',
        'Habits & Vices': 'habits',
        'Medical Ledger': 'medical',
        'Career Ledger': 'career',
        'Asset Ledger': 'assets',
        'Relational Web': 'relationalWeb',
        'Psyche Profile': 'psyche',
      };
      for (final hidden in identity.hiddenSections) {
        final key = titleToKey[hidden];
        if (key != null) blob.remove(key);
      }
    }

    return _compressToMarkdown(blob);
  }

  // ─────────────────────────────────────────────────────────────
  // Blueprint-Specific Builders
  // ─────────────────────────────────────────────────────────────

  /// Build context for resume generation.
  Future<String> buildResumeContext() => buildContextBlob(
    categories: resumeCategories,
    includeIdentity: true,
    includeHabits: true,
  );

  /// Build context for LLM system prompt export ("Grok Mode").
  Future<String> buildLlmContextExport() => buildContextBlob(
    categories: allCategories,
    includeIdentity: true,
    includeHabits: true,
  );

  /// Build context for therapist prep / clinical summary.
  Future<String> buildTherapistContext() => buildContextBlob(
    categories: therapistCategories,
    includeIdentity: true,
    includeHealth: true,
    includeRelationships: true,
  );

  // ─────────────────────────────────────────────────────────────
  // System Prompt Injection
  // ─────────────────────────────────────────────────────────────

  /// Wrap user message with RAG context as a system instruction.
  ///
  /// The returned string is the full prompt sent to the LLM.
  /// The context blob is prepended as a `<<CONTEXT>>` block.
  String wrapWithContext({
    required String userMessage,
    required String contextBlob,
    String? blueprintInstruction,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('<<ForgeVault_CONTEXT>>');
    buffer.writeln(contextBlob);
    buffer.writeln('<</ForgeVault_CONTEXT>>');

    if (blueprintInstruction != null) {
      buffer.writeln();
      buffer.writeln('<<BLUEPRINT_INSTRUCTION>>');
      buffer.writeln(blueprintInstruction);
      buffer.writeln('<</BLUEPRINT_INSTRUCTION>>');
    }

    buffer.writeln();
    buffer.writeln('<<USER_QUERY>>');
    buffer.writeln(userMessage);
    buffer.writeln('<</USER_QUERY>>');

    return buffer.toString();
  }

  /// Get a human-readable summary of what data is in the blob.
  ///
  /// Used by the Airlock Interceptor to show the user exactly
  /// what categories/counts of their data are about to leave the vault.
  Map<String, int> summarizeBlob(String contextBlob) {
    final summary = <String, int>{};
    try {
      final decoded = jsonDecode(contextBlob) as Map<String, dynamic>;
      for (final key in decoded.keys) {
        final value = decoded[key];
        if (value is List) {
          summary[key] = value.length;
        } else if (value is Map) {
          summary[key] = 1;
        }
      }
    } catch (_) {
      summary['raw'] = contextBlob.length;
    }
    return summary;
  }

  // ─────────────────────────────────────────────────────────────
  // Vault Compressor — dense Markdown format
  // ─────────────────────────────────────────────────────────────

  /// Convert the blob map into dense, token-efficient Markdown.
  ///
  /// Empty arrays, null strings, and bare keys are completely stripped.
  /// Output is roughly 60-80% smaller than pretty-printed JSON.
  static String _compressToMarkdown(Map<String, dynamic> blob) {
    if (blob.isEmpty) return '(vault empty)';

    final buf = StringBuffer();
    for (final section in blob.keys) {
      final value = blob[section];
      buf.writeln('## ${_titleCase(section)}');
      if (value is Map<String, dynamic>) {
        for (final key in value.keys) {
          final v = value[key];
          if (v is List && v.isNotEmpty) {
            buf.writeln('**$key:** ${v.join(', ')}');
          } else if (v != null && v.toString().isNotEmpty) {
            buf.writeln('**$key:** $v');
          }
        }
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            final parts = <String>[];
            for (final k in item.keys) {
              final iv = item[k];
              if (iv != null && iv.toString().isNotEmpty) {
                parts.add('$k: $iv');
              }
            }
            if (parts.isNotEmpty) buf.writeln('- ${parts.join(' | ')}');
          } else {
            buf.writeln('- $item');
          }
        }
      } else if (value != null) {
        buf.writeln(value.toString());
      }
      buf.writeln();
    }
    return buf.toString().trim();
  }

  static String _titleCase(String s) => s.replaceAllMapped(
    RegExp(r'(^|[A-Z])'),
    (m) => m.start == 0 ? m[0]!.toUpperCase() : ' ${m[0]}',
  );
}
