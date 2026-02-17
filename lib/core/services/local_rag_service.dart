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
        blob['identity'] = {
          'name': identity.fullName,
          'location': identity.location,
          'dob': identity.dateOfBirth?.toIso8601String().split('T').first,
          'traits': identity.immutableTraits,
        };
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

    return jsonEncode(blob);
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

    buffer.writeln('<<VITAVAULT_CONTEXT>>');
    buffer.writeln(contextBlob);
    buffer.writeln('<</VITAVAULT_CONTEXT>>');

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
}
