import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/schemas/core_identity.dart';
import '../database/schemas/timeline_event.dart';
import '../database/schemas/trouble.dart';
import '../database/schemas/finance_record.dart';
import '../database/schemas/relationship_node.dart';
import '../database/schemas/health_profile.dart';
import '../database/schemas/goal.dart';
import '../database/schemas/habit_vice.dart';
import '../database/schemas/medical_ledger.dart';
import '../database/schemas/career_ledger.dart';
import '../database/schemas/asset_ledger.dart';
import '../database/schemas/relational_web.dart';
import '../database/schemas/psyche_profile.dart';
import '../database/schemas/custom_ledger_section.dart';
import '../database/schemas/audit_log.dart';
import 'api_key_service.dart';
import 'gemini_nano_bridge.dart';
import 'forge_prompt.dart';
import 'forge_api_client.dart';
import 'no_api_key_exception.dart';

/// The Forge — AI synthesis orchestration layer.
///
/// 1. Receives extracted text from VacuumService
/// 2. Routes to cloud API (if BYOK configured) → Gemini Nano
/// 3. Sends system prompt + extracted text → receives structured JSON
/// 4. Parses JSON into Isar collection objects and merges into the database
class ForgeService {
  final GeminiNanoBridge _geminiNano;
  final DatabaseService _database;

  ForgeService({
    required GeminiNanoBridge geminiNano,
    required DatabaseService database,
  }) : _geminiNano = geminiNano,
       _database = database;

  /// Synthesize extracted text AND auto-commit to Isar.
  ///
  /// Routes to the best available LLM backend:
  ///   - Cloud API (Grok/Claude/Gemini if BYOK configured)
  ///   - Android → Gemini Nano (if available)
  ///   - Throws NoApiKeyException if nothing is configured
  Future<ForgeResult> synthesize(String extractedText) async {
    final result = await synthesizeWithReview(extractedText);
    await _mergeIntoDatabase(result);
    await _writeAuditLog('FORGE_SYNTHESIS');
    return result;
  }

  /// Synthesize WITHOUT auto-committing — for Diff Review flow.
  ///
  /// Returns the parsed ForgeResult for user review/editing before commit.
  Future<ForgeResult> synthesizeWithReview(String extractedText) async {
    // Fetch current vault state for context-aware synthesis
    String? vaultState;
    try {
      vaultState = await _database.getBioContextString();
      if (vaultState.trim().isEmpty) vaultState = null;
    } catch (_) {
      // DB may not be ready yet — proceed without context
    }

    // Fetch custom ledger titles and hidden sections for AI bridge
    List<String> customTitles = [];
    List<String> hiddenSections = [];
    try {
      final customSections = await _database.db.customLedgerSections
          .where()
          .findAll();
      customTitles = customSections.map((s) => s.title).toList();
      final identity = await _database.db.coreIdentitys.where().findFirst();
      hiddenSections = identity?.hiddenSections ?? [];
    } catch (_) {}

    final prompt = ForgePrompt.buildPrompt(
      extractedText,
      vaultState: vaultState,
      customLedgerTitles: customTitles,
      hiddenSections: hiddenSections,
    );
    String rawJson;

    debugPrint('Forge: processing text (${extractedText.length} chars)');

    // Priority 1: Cloud API — dynamically fetch keys from ApiKeyService.
    // A fresh instance is created every call to avoid any cached state.
    final keyService = ApiKeyService();
    final activeProvider = await keyService.getActiveProvider();

    if (activeProvider != null) {
      final key = await keyService.getApiKey(activeProvider);
      if (key != null && key.trim().isNotEmpty) {
        // If a key exists, the cloud call MUST succeed or throw the real error.
        final client = ForgeApiClient(keyService: keyService);
        rawJson = await client.synthesize(
          extractedText,
          vaultState: vaultState,
        );
        final result = _parseForgeJson(rawJson);
        return _prepareForReview(result);
      }
    }

    // Priority 2: Gemini Nano (Android only)
    if (Platform.isAndroid) {
      final nanoAvailable = await _geminiNano.isAvailable();
      if (nanoAvailable) {
        rawJson = await _geminiNano.generateJson(
          prompt: prompt,
          systemPrompt: ForgePrompt.systemPrompt,
        );
        final result = _parseForgeJson(rawJson);
        return _prepareForReview(result);
      }
    }

    // No backend available.
    throw NoApiKeyException('No API Key configured. Go to Engine Room.');
  }

  /// Commit a reviewed ForgeResult to Isar.
  Future<void> commitReviewedResult(ForgeResult result) async {
    await _mergeIntoDatabase(result);
    await _writeAuditLog('FORGE_SYNTHESIS_REVIEWED');
  }

  /// Check if any LLM backend is available.
  Future<bool> isAvailable() async {
    final keyService = ApiKeyService();
    final provider = await keyService.getActiveProvider();
    if (provider != null) return true;
    if (Platform.isAndroid) {
      return _geminiNano.isAvailable();
    }
    return false;
  }

  // ── Private: JSON Parsing ──

  ForgeResult _parseForgeJson(String rawJson) {
    debugPrint('Forge: parsing AI response (${rawJson.length} chars)');

    // Strip markdown code fences that LLMs love to wrap JSON in.
    // Handles: ```json, ```JSON, ```\n{...}\n```, etc.
    var cleaned = rawJson.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```\w*\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*$', multiLine: true), '');
    cleaned = cleaned.trim();

    // Absolute substring extraction — find the actual JSON object
    // even if Claude/GPT added conversational text before/after.
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw ForgeException('LLM failed to output JSON. Response: $cleaned');
    }
    if (end > start) {
      cleaned = cleaned.substring(start, end + 1);
    }

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return ForgeResult.fromJson(json);
    } catch (e) {
      throw ForgeException('Failed to parse Forge JSON output: $e');
    }
  }

  // ── Private: Pre-Review Alignment ──

  /// Align LLM output with existing DB records BEFORE the review screen.
  ///
  /// Sets Isar IDs so put() overwrites the correct records, fills in
  /// empty identity fields from existing data, fuzzy-matches titles,
  /// and deduplicates timeline events.
  Future<ForgeResult> _prepareForReview(ForgeResult result) async {
    final db = _database.db;

    // ── 0. PRUNING ENGINE — process AI-requested deletions first ──
    if (result.recordsToRemove.isNotEmpty) {
      await _applyRemovals(db, result.recordsToRemove);
    }

    // ── 1. IDENTITY ALIGNMENT ──
    final existingId = await db.coreIdentitys.where().findFirst();
    if (existingId != null && result.identity != null) {
      final llm = result.identity!;
      // Assign Isar ID so put() overwrites the singleton
      llm.id = existingId.id;

      // ── Name Bouncer: reject garbage names ──
      final newName = llm.fullName.trim();
      final lowerName = newName.toLowerCase();
      const junkNames = {'unknown', 'n/a', 'none', 'null', ''};

      if (junkNames.contains(lowerName)) {
        // LLM gave a junk name — keep existing
        llm.fullName = existingId.fullName;
      } else if (existingId.fullName.isNotEmpty &&
          existingId.fullName != 'Unknown' &&
          newName != existingId.fullName) {
        // Genuine rename — store old name as alias
        final previousTag = 'Previous Name: ${existingId.fullName}';
        llm.immutableTraits ??= [];
        if (!llm.immutableTraits!.contains(previousTag)) {
          llm.immutableTraits!.add(previousTag);
        }
        // Keep the NEW LLM name
      }

      // Fallback empty/null LLM fields to existing values
      llm.dateOfBirth ??= existingId.dateOfBirth;
      if (llm.location.isEmpty) llm.location = existingId.location;

      // ── Set-based merge for ALL list fields (fuzzy dedup) ──
      llm.immutableTraits = _mergeListsFuzzy(
        existingId.immutableTraits,
        llm.immutableTraits,
      );
      llm.locationHistory = _mergeListsFuzzy(
        existingId.locationHistory,
        llm.locationHistory,
      );
      llm.familyLineage = _mergeListsFuzzy(
        existingId.familyLineage,
        llm.familyLineage,
      );

      llm.lastUpdated = DateTime.now();
    }

    // ── 2. TROUBLE ID MATCHING (fuzzy) ──
    final allTroubles = await db.troubles.where().findAll();
    for (final newT in result.troubles) {
      final match = _fuzzyFindMatch(
        allTroubles,
        newT.title,
        (Trouble t) => t.title,
      );
      if (match != null) {
        newT.id = match.id;
        newT.title = match.title; // Retain the canonical title
      }
    }

    // ── 3. GOAL ID MATCHING (fuzzy) ──
    final allGoals = await db.goals.where().findAll();
    for (final newG in result.goals) {
      final match = _fuzzyFindMatch(allGoals, newG.title, (Goal g) => g.title);
      if (match != null) {
        newG.id = match.id;
        newG.title = match.title;
      }
    }

    // ── 4. HABIT/VICE ID MATCHING (fuzzy) ──
    final allHV = await db.habitVices.where().findAll();
    for (final newHV in result.habitsVices) {
      final match = _fuzzyFindMatch(allHV, newHV.name, (HabitVice h) => h.name);
      if (match != null) {
        newHV.id = match.id;
        newHV.name = match.name;
      }
    }

    // ── 5. HEALTH ALIGNMENT ──
    final existingHealth = await db.healthProfiles.where().findFirst();
    if (existingHealth != null && result.healthProfile != null) {
      result.healthProfile!.id = existingHealth.id;
    }

    // ── 6. TIMELINE DEDUPLICATION ──
    final allEvents = await db.timelineEvents.where().findAll();
    final cleanEvents = <TimelineEvent>[];
    for (final newE in result.timelineEvents) {
      if (_isTimelineDuplicate(newE, allEvents, cleanEvents)) continue;
      cleanEvents.add(newE);
    }
    result.timelineEvents = cleanEvents;

    // ── 7. MEDICAL LEDGER ALIGNMENT ──
    final existingMedical = await db.medicalLedgers.where().findFirst();
    if (existingMedical != null && result.medicalLedger != null) {
      final m = result.medicalLedger!;
      m.id = existingMedical.id;
      m.surgeries = _mergeListsFuzzy(existingMedical.surgeries, m.surgeries);
      m.genetics = _mergeListsFuzzy(existingMedical.genetics, m.genetics);
      m.vitalBaselines = _mergeListsFuzzy(
        existingMedical.vitalBaselines,
        m.vitalBaselines,
      );
      m.visionRx = _mergeListsFuzzy(existingMedical.visionRx, m.visionRx);
      m.familyMedicalHistory = _mergeListsFuzzy(
        existingMedical.familyMedicalHistory,
        m.familyMedicalHistory,
      );
      m.bloodwork = _mergeListsFuzzy(existingMedical.bloodwork, m.bloodwork);
      m.immunizations = _mergeListsFuzzy(
        existingMedical.immunizations,
        m.immunizations,
      );
      m.dentalHistory = _mergeListsFuzzy(
        existingMedical.dentalHistory,
        m.dentalHistory,
      );
    }

    // ── 8. CAREER LEDGER ALIGNMENT ──
    final existingCareer = await db.careerLedgers.where().findFirst();
    if (existingCareer != null && result.careerLedger != null) {
      final c = result.careerLedger!;
      c.id = existingCareer.id;
      c.jobs = _mergeListsFuzzy(existingCareer.jobs, c.jobs);
      c.degrees = _mergeListsFuzzy(existingCareer.degrees, c.degrees);
      c.certifications = _mergeListsFuzzy(
        existingCareer.certifications,
        c.certifications,
      );
      c.clearances = _mergeListsFuzzy(existingCareer.clearances, c.clearances);
      c.skills = _mergeListsFuzzy(existingCareer.skills, c.skills);
      c.projects = _mergeListsFuzzy(existingCareer.projects, c.projects);
      c.businesses = _mergeListsFuzzy(existingCareer.businesses, c.businesses);
    }

    // ── 9. ASSET LEDGER ALIGNMENT ──
    final existingAssets = await db.assetLedgers.where().findFirst();
    if (existingAssets != null && result.assetLedger != null) {
      final a = result.assetLedger!;
      a.id = existingAssets.id;
      a.realEstate = _mergeListsFuzzy(existingAssets.realEstate, a.realEstate);
      a.vehicles = _mergeListsFuzzy(existingAssets.vehicles, a.vehicles);
      a.digitalAssets = _mergeListsFuzzy(
        existingAssets.digitalAssets,
        a.digitalAssets,
      );
      a.insurance = _mergeListsFuzzy(existingAssets.insurance, a.insurance);
      a.investments = _mergeListsFuzzy(
        existingAssets.investments,
        a.investments,
      );
      a.valuables = _mergeListsFuzzy(existingAssets.valuables, a.valuables);
      a.equityStakes = _mergeListsFuzzy(
        existingAssets.equityStakes,
        a.equityStakes,
      );
    }

    // ── 10. RELATIONAL WEB ALIGNMENT ──
    final existingRelWeb = await db.relationalWebs.where().findFirst();
    if (existingRelWeb != null && result.relationalWeb != null) {
      final r = result.relationalWeb!;
      r.id = existingRelWeb.id;
      r.family = _mergeListsFuzzy(existingRelWeb.family, r.family);
      r.mentors = _mergeListsFuzzy(existingRelWeb.mentors, r.mentors);
      r.adversaries = _mergeListsFuzzy(
        existingRelWeb.adversaries,
        r.adversaries,
      );
      r.colleagues = _mergeListsFuzzy(existingRelWeb.colleagues, r.colleagues);
      r.friends = _mergeListsFuzzy(existingRelWeb.friends, r.friends);
    }

    // ── 11. PSYCHE PROFILE ALIGNMENT ──
    final existingPsyche = await db.psycheProfiles.where().findFirst();
    if (existingPsyche != null && result.psycheProfile != null) {
      final p = result.psycheProfile!;
      p.id = existingPsyche.id;
      p.beliefs = _mergeListsFuzzy(existingPsyche.beliefs, p.beliefs);
      p.personality = _mergeListsFuzzy(
        existingPsyche.personality,
        p.personality,
      );
      p.fears = _mergeListsFuzzy(existingPsyche.fears, p.fears);
      p.motivations = _mergeListsFuzzy(
        existingPsyche.motivations,
        p.motivations,
      );
      p.strengths = _mergeListsFuzzy(existingPsyche.strengths, p.strengths);
      p.weaknesses = _mergeListsFuzzy(existingPsyche.weaknesses, p.weaknesses);
      // Scalars: prefer new non-null values over existing
      p.enneagram ??= existingPsyche.enneagram;
      p.mbti ??= existingPsyche.mbti;
    }

    return result;
  }

  // ── Private: Database Save (with fuzzy dedup on all arrays) ──

  Future<void> _mergeIntoDatabase(ForgeResult result) async {
    final db = _database.db;

    await db.writeTxn(() async {
      // ── Identity (merge arrays) ──
      if (result.identity != null) {
        final existing = await db.coreIdentitys.where().findFirst();
        if (existing != null) {
          final merged = result.identity!;
          merged.id = existing.id;
          merged.immutableTraits = _mergeListsFuzzy(
            existing.immutableTraits,
            merged.immutableTraits,
          );
          merged.locationHistory = _mergeListsFuzzy(
            existing.locationHistory,
            merged.locationHistory,
          );
          merged.familyLineage = _mergeListsFuzzy(
            existing.familyLineage,
            merged.familyLineage,
          );
          // Preserve non-empty existing scalars
          if (merged.fullName.isEmpty && existing.fullName.isNotEmpty) {
            merged.fullName = existing.fullName;
          }
          if (merged.location.isEmpty && existing.location.isNotEmpty) {
            merged.location = existing.location;
          }
          merged.dateOfBirth ??= existing.dateOfBirth;
          // Preserve user preferences not set by the LLM
          merged.hiddenSections = existing.hiddenSections;
        }
        await db.coreIdentitys.put(result.identity!);
      }

      for (final event in result.timelineEvents) {
        await db.timelineEvents.put(event);
      }
      for (final trouble in result.troubles) {
        await db.troubles.put(trouble);
      }
      for (final finance in result.finances) {
        await db.financeRecords.put(finance);
      }
      for (final rel in result.relationships) {
        await db.relationshipNodes.put(rel);
      }
      if (result.healthProfile != null) {
        final existing = await db.healthProfiles.where().findFirst();
        if (existing != null) {
          final hp = result.healthProfile!;
          hp.id = existing.id;
          hp.conditions = _mergeListsFuzzy(existing.conditions, hp.conditions);
          hp.medications = _mergeListsFuzzy(
            existing.medications,
            hp.medications,
          );
          hp.allergies = _mergeListsFuzzy(existing.allergies, hp.allergies);
          hp.labResults = _mergeListsFuzzy(existing.labResults, hp.labResults);
          if ((hp.bloodType == null || hp.bloodType!.isEmpty) &&
              existing.bloodType != null) {
            hp.bloodType = existing.bloodType;
          }
        }
        await db.healthProfiles.put(result.healthProfile!);
      }
      for (final goal in result.goals) {
        await db.goals.put(goal);
      }
      for (final hv in result.habitsVices) {
        await db.habitVices.put(hv);
      }

      // ── Medical Ledger (merge ALL arrays) ──
      if (result.medicalLedger != null) {
        final existing = await db.medicalLedgers.where().findFirst();
        if (existing != null) {
          final m = result.medicalLedger!;
          m.id = existing.id;
          m.surgeries = _mergeListsFuzzy(existing.surgeries, m.surgeries);
          m.genetics = _mergeListsFuzzy(existing.genetics, m.genetics);
          m.vitalBaselines = _mergeListsFuzzy(
            existing.vitalBaselines,
            m.vitalBaselines,
          );
          m.visionRx = _mergeListsFuzzy(existing.visionRx, m.visionRx);
          m.familyMedicalHistory = _mergeListsFuzzy(
            existing.familyMedicalHistory,
            m.familyMedicalHistory,
          );
          m.bloodwork = _mergeListsFuzzy(existing.bloodwork, m.bloodwork);
          m.immunizations = _mergeListsFuzzy(
            existing.immunizations,
            m.immunizations,
          );
          m.dentalHistory = _mergeListsFuzzy(
            existing.dentalHistory,
            m.dentalHistory,
          );
        }
        await db.medicalLedgers.put(result.medicalLedger!);
      }

      // ── Career Ledger (merge ALL arrays) ──
      if (result.careerLedger != null) {
        final existing = await db.careerLedgers.where().findFirst();
        if (existing != null) {
          final c = result.careerLedger!;
          c.id = existing.id;
          c.jobs = _mergeListsFuzzy(existing.jobs, c.jobs);
          c.degrees = _mergeListsFuzzy(existing.degrees, c.degrees);
          c.certifications = _mergeListsFuzzy(
            existing.certifications,
            c.certifications,
          );
          c.clearances = _mergeListsFuzzy(existing.clearances, c.clearances);
          c.skills = _mergeListsFuzzy(existing.skills, c.skills);
          c.projects = _mergeListsFuzzy(existing.projects, c.projects);
          c.businesses = _mergeListsFuzzy(existing.businesses, c.businesses);
        }
        await db.careerLedgers.put(result.careerLedger!);
      }

      // ── Asset Ledger (merge ALL arrays) ──
      if (result.assetLedger != null) {
        final existing = await db.assetLedgers.where().findFirst();
        if (existing != null) {
          final a = result.assetLedger!;
          a.id = existing.id;
          a.realEstate = _mergeListsFuzzy(existing.realEstate, a.realEstate);
          a.vehicles = _mergeListsFuzzy(existing.vehicles, a.vehicles);
          a.digitalAssets = _mergeListsFuzzy(
            existing.digitalAssets,
            a.digitalAssets,
          );
          a.insurance = _mergeListsFuzzy(existing.insurance, a.insurance);
          a.investments = _mergeListsFuzzy(existing.investments, a.investments);
          a.valuables = _mergeListsFuzzy(existing.valuables, a.valuables);
          a.equityStakes = _mergeListsFuzzy(
            existing.equityStakes,
            a.equityStakes,
          );
        }
        await db.assetLedgers.put(result.assetLedger!);
      }

      // ── Relational Web (merge ALL arrays) ──
      if (result.relationalWeb != null) {
        final existing = await db.relationalWebs.where().findFirst();
        if (existing != null) {
          final r = result.relationalWeb!;
          r.id = existing.id;
          r.family = _mergeListsFuzzy(existing.family, r.family);
          r.mentors = _mergeListsFuzzy(existing.mentors, r.mentors);
          r.adversaries = _mergeListsFuzzy(existing.adversaries, r.adversaries);
          r.colleagues = _mergeListsFuzzy(existing.colleagues, r.colleagues);
          r.friends = _mergeListsFuzzy(existing.friends, r.friends);
        }
        await db.relationalWebs.put(result.relationalWeb!);
      }

      // ── Psyche Profile (merge ALL arrays) ──
      if (result.psycheProfile != null) {
        final existing = await db.psycheProfiles.where().findFirst();
        if (existing != null) {
          final p = result.psycheProfile!;
          p.id = existing.id;
          p.beliefs = _mergeListsFuzzy(existing.beliefs, p.beliefs);
          p.personality = _mergeListsFuzzy(existing.personality, p.personality);
          p.fears = _mergeListsFuzzy(existing.fears, p.fears);
          p.motivations = _mergeListsFuzzy(existing.motivations, p.motivations);
          p.strengths = _mergeListsFuzzy(existing.strengths, p.strengths);
          p.weaknesses = _mergeListsFuzzy(existing.weaknesses, p.weaknesses);
          if ((p.enneagram == null || p.enneagram!.isEmpty) &&
              existing.enneagram != null) {
            p.enneagram = existing.enneagram;
          }
          if ((p.mbti == null || p.mbti!.isEmpty) && existing.mbti != null) {
            p.mbti = existing.mbti;
          }
        }
        await db.psycheProfiles.put(result.psycheProfile!);
      }

      // ── Custom Ledgers (merge into existing sections) ──
      if (result.customLedgers.isNotEmpty) {
        for (final entry in result.customLedgers.entries) {
          if (entry.value.isEmpty) continue;
          // Find existing section by title
          final existing = await db.customLedgerSections
              .filter()
              .titleEqualTo(entry.key)
              .findFirst();
          if (existing != null) {
            // Merge by name dedup: skip items whose name already exists
            final existingNames = existing.items
                .map((i) => (i.name ?? '').toLowerCase().trim())
                .toSet();
            for (final newItem in entry.value) {
              final key = (newItem.name ?? '').toLowerCase().trim();
              if (key.isNotEmpty && !existingNames.contains(key)) {
                existing.items = [...existing.items, newItem];
                existingNames.add(key);
              }
            }
            existing.lastUpdated = DateTime.now();
            await db.customLedgerSections.put(existing);
          }
          // If no existing section, skip — the user must create it first
        }
      }
    });

    // ── Audit: log successful ingestion ──
    final fieldCount = [
      if (result.identity != null) 1,
      result.timelineEvents.length,
      result.troubles.length,
      result.finances.length,
      result.relationships.length,
      result.healthProfile != null ? 1 : 0,
      result.goals.length,
      result.habitsVices.length,
      result.medicalLedger != null ? 1 : 0,
      result.careerLedger != null ? 1 : 0,
      result.assetLedger != null ? 1 : 0,
      result.relationalWeb != null ? 1 : 0,
      result.psycheProfile != null ? 1 : 0,
      result.customLedgers.length,
    ].fold<int>(0, (sum, v) => sum + v);
    await _database.addAuditLog(
      'Ingestion Complete',
      'Extracted $fieldCount fields/records from document.',
      aiSummary: result.aiSummary,
    );
  }

  /// Fuzzy match: finds existing record where either title contains the
  /// other (case-insensitive). Returns the matched existing record or null.
  static T? _fuzzyFindMatch<T>(
    List<T> existingItems,
    String newTitle,
    String Function(T) titleGetter,
  ) {
    final lower = newTitle.toLowerCase();
    for (final item in existingItems) {
      final existingLower = titleGetter(item).toLowerCase();
      if (existingLower.contains(lower) || lower.contains(existingLower)) {
        return item;
      }
    }
    return null;
  }

  /// Normalize a string for aggressive dedup comparison:
  /// lowercase, strip ALL punctuation/symbols/digits, collapse whitespace.
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z\s]'),
          '',
        ) // strip everything except a-z and spaces
        .replaceAll(RegExp(r'\s+'), ' ') // collapse whitespace
        .trim();
  }

  /// Aggressive fuzzy list merge: combines [existing] and [incoming] lists,
  /// silently dropping incoming entries that match existing ones after
  /// aggressive normalization (strip punctuation, symbols, digits).
  ///
  /// Uses bidirectional substring check on normalized forms, plus
  /// Jaccard word-overlap similarity as a fallback for semantic matches
  /// (e.g., "B.S. Cybersecurity" ≈ "Bachelor of Science, Cybersecurity").
  static List<String>? _mergeListsFuzzy(
    List<String>? existing,
    List<String>? incoming,
  ) {
    if (existing == null && incoming == null) return null;
    if (existing == null || existing.isEmpty) return incoming;
    if (incoming == null || incoming.isEmpty) return existing;

    // First, deduplicate the existing list itself
    final deduped = _deduplicateList(existing);
    final result = List<String>.from(deduped!);
    final existingNorm = result.map(_normalize).toList();

    for (final entry in incoming) {
      final entryNorm = _normalize(entry);
      if (entryNorm.isEmpty) continue;

      // Check if any existing entry matches via bidirectional substring
      bool isDuplicate = false;
      for (final existNorm in existingNorm) {
        // Pass 1: exact or substring match
        if (existNorm == entryNorm ||
            existNorm.contains(entryNorm) ||
            entryNorm.contains(existNorm)) {
          isDuplicate = true;
          break;
        }
        // Pass 2: Jaccard word-overlap similarity
        if (_jaccardSimilar(existNorm, entryNorm)) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        result.add(entry);
        existingNorm.add(entryNorm);
      }
    }

    return result;
  }

  /// Stop words stripped before Jaccard comparison — academic/degree
  /// abbreviations, articles, and common structural terms.
  static final _stopWords = <String>{
    'of',
    'and',
    'in',
    'at',
    'the',
    'a',
    'an',
    'for',
    'to',
    'bachelor',
    'bachelors',
    'master',
    'masters',
    'bs',
    'ms',
    'ba',
    'ma',
    'phd',
    'associate',
    'associates',
    'degree',
    'university',
    'college',
    'institute',
    'certification',
    'certified',
    'certificate',
  };

  /// Jaccard word-overlap similarity:
  /// tokenize both strings, remove stop words, compute intersection
  /// ratio relative to the shorter token set. Returns true if > 60%.
  static bool _jaccardSimilar(String normA, String normB) {
    final tokA = _tokenize(normA);
    final tokB = _tokenize(normB);
    if (tokA.isEmpty || tokB.isEmpty) return false;

    final intersection = tokA.intersection(tokB).length;
    final shorter = tokA.length < tokB.length ? tokA.length : tokB.length;
    return intersection / shorter > 0.6;
  }

  /// Tokenize a normalized string into a set of keywords,
  /// stripping stop words.
  static Set<String> _tokenize(String norm) {
    return norm
        .split(' ')
        .where((w) => w.isNotEmpty && !_stopWords.contains(w))
        .toSet();
  }

  /// Deduplicate an existing list in-place using aggressive normalization.
  /// Keeps the first occurrence, drops later duplicates.
  static List<String>? _deduplicateList(List<String>? list) {
    if (list == null || list.length < 2) return list;

    final seen = <String>{};
    final result = <String>[];

    for (final entry in list) {
      final norm = _normalize(entry);
      if (norm.isEmpty) {
        result.add(entry); // keep blanks
        continue;
      }

      // Check bidirectional substring against everything already seen
      bool isDup = false;
      for (final s in seen) {
        if (s == norm || s.contains(norm) || norm.contains(s)) {
          isDup = true;
          break;
        }
      }

      if (!isDup) {
        seen.add(norm);
        result.add(entry);
      }
    }

    return result;
  }

  /// Timeline deduplication: checks if an event with the same year and
  /// a matching keyword (first word > 4 chars) already exists.
  static bool _isTimelineDuplicate(
    TimelineEvent newEvent,
    List<TimelineEvent> dbEvents,
    List<TimelineEvent> cleanEvents,
  ) {
    final newYear = newEvent.eventDate.year;
    final newKeyword = _extractKeyword(newEvent.title);

    for (final existing in [...dbEvents, ...cleanEvents]) {
      if (existing.eventDate.year != newYear) continue;
      if (newKeyword != null) {
        final existingLower = existing.title.toLowerCase();
        if (existingLower.contains(newKeyword)) return true;
      }
      // Also check full fuzzy title match
      final existingLower = existing.title.toLowerCase();
      final newLower = newEvent.title.toLowerCase();
      if (existingLower.contains(newLower) ||
          newLower.contains(existingLower)) {
        return true;
      }
    }
    return false;
  }

  /// Apply AI-requested removals by fuzzy-matching against stored data.
  static Future<void> _applyRemovals(
    Isar db,
    List<RemovalDirective> removals,
  ) async {
    final byLedger = <String, List<RemovalDirective>>{};
    for (final r in removals) {
      byLedger.putIfAbsent(r.ledger, () => []).add(r);
    }

    await db.writeTxn(() async {
      // ── Identity ──
      if (byLedger.containsKey('identity')) {
        var id = await db.coreIdentitys.where().findFirst();
        if (id != null) {
          for (final r in byLedger['identity']!) {
            switch (r.field) {
              case 'immutabletraits':
                id.immutableTraits = _removeFromList(
                  id.immutableTraits,
                  r.value,
                );
              case 'locationhistory':
                id.locationHistory = _removeFromList(
                  id.locationHistory,
                  r.value,
                );
              case 'familylineage':
                id.familyLineage = _removeFromList(id.familyLineage, r.value);
            }
          }
          await db.coreIdentitys.put(id);
        }
      }

      // ── Medical ──
      if (byLedger.containsKey('medical')) {
        var m = await db.medicalLedgers.where().findFirst();
        if (m != null) {
          for (final r in byLedger['medical']!) {
            switch (r.field) {
              case 'surgeries':
                m.surgeries = _removeFromList(m.surgeries, r.value);
              case 'genetics':
                m.genetics = _removeFromList(m.genetics, r.value);
              case 'vitalbaselines':
                m.vitalBaselines = _removeFromList(m.vitalBaselines, r.value);
              case 'visionrx':
                m.visionRx = _removeFromList(m.visionRx, r.value);
              case 'familymedicalhistory':
                m.familyMedicalHistory = _removeFromList(
                  m.familyMedicalHistory,
                  r.value,
                );
              case 'bloodwork':
                m.bloodwork = _removeFromList(m.bloodwork, r.value);
              case 'immunizations':
                m.immunizations = _removeFromList(m.immunizations, r.value);
              case 'dentalhistory':
                m.dentalHistory = _removeFromList(m.dentalHistory, r.value);
            }
          }
          await db.medicalLedgers.put(m);
        }
      }

      // ── Career ──
      if (byLedger.containsKey('career')) {
        var c = await db.careerLedgers.where().findFirst();
        if (c != null) {
          for (final r in byLedger['career']!) {
            switch (r.field) {
              case 'jobs':
                c.jobs = _removeFromList(c.jobs, r.value);
              case 'degrees':
                c.degrees = _removeFromList(c.degrees, r.value);
              case 'certifications':
                c.certifications = _removeFromList(c.certifications, r.value);
              case 'clearances':
                c.clearances = _removeFromList(c.clearances, r.value);
              case 'skills':
                c.skills = _removeFromList(c.skills, r.value);
              case 'projects':
                c.projects = _removeFromList(c.projects, r.value);
              case 'businesses':
                c.businesses = _removeFromList(c.businesses, r.value);
            }
          }
          await db.careerLedgers.put(c);
        }
      }

      // ── Assets ──
      if (byLedger.containsKey('assets')) {
        var a = await db.assetLedgers.where().findFirst();
        if (a != null) {
          for (final r in byLedger['assets']!) {
            switch (r.field) {
              case 'realestate':
                a.realEstate = _removeFromList(a.realEstate, r.value);
              case 'vehicles':
                a.vehicles = _removeFromList(a.vehicles, r.value);
              case 'digitalassets':
                a.digitalAssets = _removeFromList(a.digitalAssets, r.value);
              case 'insurance':
                a.insurance = _removeFromList(a.insurance, r.value);
              case 'investments':
                a.investments = _removeFromList(a.investments, r.value);
              case 'valuables':
                a.valuables = _removeFromList(a.valuables, r.value);
              case 'equitystakes':
                a.equityStakes = _removeFromList(a.equityStakes, r.value);
            }
          }
          await db.assetLedgers.put(a);
        }
      }

      // ── Relational Web ──
      if (byLedger.containsKey('relationalweb')) {
        var rw = await db.relationalWebs.where().findFirst();
        if (rw != null) {
          for (final r in byLedger['relationalweb']!) {
            switch (r.field) {
              case 'family':
                rw.family = _removeFromList(rw.family, r.value);
              case 'mentors':
                rw.mentors = _removeFromList(rw.mentors, r.value);
              case 'adversaries':
                rw.adversaries = _removeFromList(rw.adversaries, r.value);
              case 'colleagues':
                rw.colleagues = _removeFromList(rw.colleagues, r.value);
              case 'friends':
                rw.friends = _removeFromList(rw.friends, r.value);
            }
          }
          await db.relationalWebs.put(rw);
        }
      }

      // ── Psyche ──
      if (byLedger.containsKey('psyche')) {
        var p = await db.psycheProfiles.where().findFirst();
        if (p != null) {
          for (final r in byLedger['psyche']!) {
            switch (r.field) {
              case 'beliefs':
                p.beliefs = _removeFromList(p.beliefs, r.value);
              case 'personality':
                p.personality = _removeFromList(p.personality, r.value);
              case 'fears':
                p.fears = _removeFromList(p.fears, r.value);
              case 'motivations':
                p.motivations = _removeFromList(p.motivations, r.value);
              case 'strengths':
                p.strengths = _removeFromList(p.strengths, r.value);
              case 'weaknesses':
                p.weaknesses = _removeFromList(p.weaknesses, r.value);
            }
          }
          await db.psycheProfiles.put(p);
        }
      }
    });

    debugPrint(
      'PRUNING ENGINE: Processed ${removals.length} removal directives',
    );
  }

  /// Remove entries from a list using fuzzy substring matching.
  static List<String>? _removeFromList(List<String>? list, String value) {
    if (list == null || list.isEmpty) return list;
    final valueLower = value.toLowerCase().trim();
    return list.where((entry) {
      final entryLower = entry.toLowerCase().trim();
      return !(entryLower == valueLower ||
          entryLower.contains(valueLower) ||
          valueLower.contains(entryLower));
    }).toList();
  }

  /// Extract first word > 4 chars from a title as a keyword for dedup.
  static String? _extractKeyword(String title) {
    final words = title.toLowerCase().split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.length > 4) return word;
    }
    return null;
  }

  Future<void> _writeAuditLog(String action) async {
    final db = _database.db;
    await db.writeTxn(() async {
      await db.auditLogs.put(
        AuditLog()
          ..timestamp = DateTime.now()
          ..action = action
          ..details = 'Forge synthesis complete',
      );
    });
  }
}

/// Represents a single AI-requested deletion.
class RemovalDirective {
  final String ledger;
  final String field;
  final String value;
  const RemovalDirective({
    required this.ledger,
    required this.field,
    required this.value,
  });
}

/// Parsed result from the Forge LLM synthesis.
class ForgeResult {
  CoreIdentity? identity;
  List<TimelineEvent> timelineEvents;
  List<Trouble> troubles;
  List<FinanceRecord> finances;
  List<RelationshipNode> relationships;
  HealthProfile? healthProfile;
  List<Goal> goals;
  List<HabitVice> habitsVices;
  MedicalLedger? medicalLedger;
  CareerLedger? careerLedger;
  AssetLedger? assetLedger;
  RelationalWeb? relationalWeb;
  PsycheProfile? psycheProfile;
  List<String> changelog;
  List<RemovalDirective> recordsToRemove;
  Map<String, List<CustomItem>> customLedgers;
  String? aiSummary;

  ForgeResult({
    this.identity,
    this.timelineEvents = const [],
    this.troubles = const [],
    this.finances = const [],
    this.relationships = const [],
    this.healthProfile,
    this.goals = const [],
    this.habitsVices = const [],
    this.medicalLedger,
    this.careerLedger,
    this.assetLedger,
    this.relationalWeb,
    this.psycheProfile,
    this.changelog = const [],
    this.recordsToRemove = const [],
    this.customLedgers = const {},
    this.aiSummary,
  });

  factory ForgeResult.fromJson(Map<String, dynamic> json) {
    MedicalLedger? medicalLedger;
    try {
      if (json['medical'] != null) {
        medicalLedger = _parseMedical(json['medical']);
      }
    } catch (e) {
      debugPrint('PARSER ERROR IN MEDICAL: $e');
    }

    CareerLedger? careerLedger;
    try {
      if (json['career'] != null) {
        careerLedger = _parseCareer(json['career']);
      }
    } catch (e) {
      debugPrint('PARSER ERROR IN CAREER: $e');
    }

    AssetLedger? assetLedger;
    try {
      if (json['assets'] != null) {
        assetLedger = _parseAssets(json['assets']);
      }
    } catch (e) {
      debugPrint('PARSER ERROR IN ASSETS: $e');
    }

    RelationalWeb? relationalWeb;
    try {
      if (json['relationalWeb'] != null) {
        relationalWeb = _parseRelationalWeb(json['relationalWeb']);
      }
    } catch (e) {
      debugPrint('PARSER ERROR IN RELATIONAL WEB: $e');
    }

    PsycheProfile? psycheProfile;
    try {
      if (json['psyche'] != null) {
        psycheProfile = _parsePsyche(json['psyche']);
      }
    } catch (e) {
      debugPrint('PARSER ERROR IN PSYCHE: $e');
    }

    return ForgeResult(
      identity: _parseIdentity(json['identity']),
      timelineEvents: _parseTimelineEvents(json['timelineEvents']),
      troubles: _parseTroubles(json['troubles']),
      finances: _parseFinances(json['finances']),
      relationships: _parseRelationships(json['relationships']),
      healthProfile: _parseHealth(json['health']),
      goals: _parseGoals(json['goals']),
      habitsVices: _parseHabitsVices(json['habitsVices']),
      medicalLedger: medicalLedger,
      careerLedger: careerLedger,
      assetLedger: assetLedger,
      relationalWeb: relationalWeb,
      psycheProfile: psycheProfile,
      changelog: _parseStringList(json['changelog']),
      recordsToRemove: _parseRemovals(json['recordsToRemove']),
      customLedgers: _parseCustomLedgers(json['customLedgers']),
      aiSummary: json['aiSummary'] as String?,
    );
  }

  // ── Parsers ──

  static CoreIdentity? _parseIdentity(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return CoreIdentity()
      ..fullName = data['fullName'] as String? ?? ''
      ..dateOfBirth = _parseDate(data['dateOfBirth'])
      ..location = data['location'] as String? ?? ''
      ..immutableTraits = _parseStringList(data['immutableTraits'])
      ..locationHistory = _parseStringList(data['locationHistory'])
      ..familyLineage = _parseStringList(data['familyLineage'])
      ..lastUpdated = DateTime.now()
      ..completenessScore = 0;
  }

  static List<TimelineEvent> _parseTimelineEvents(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      final te = TimelineEvent()
        ..eventDate = _parseDate(e['eventDate']) ?? DateTime.now()
        ..title = e['title'] as String? ?? ''
        ..description = e['description'] as String? ?? ''
        ..category = e['category'] as String? ?? 'Personal'
        ..emotionalImpactScore =
            (e['emotionalImpactScore'] as num?)?.toInt() ?? 1
        ..isVerified = e['isVerified'] as bool? ?? false;
      if (e['id'] != null) te.id = (e['id'] as num).toInt();
      return te;
    }).toList();
  }

  static List<Trouble> _parseTroubles(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      final t = Trouble()
        ..title = e['title'] as String? ?? ''
        ..detailText = e['detailText'] as String? ?? ''
        ..category = e['category'] as String? ?? ''
        ..severity = (e['severity'] as num?)?.toInt() ?? 1
        ..isResolved = e['isResolved'] as bool? ?? false
        ..dateIdentified = _parseDate(e['dateIdentified']) ?? DateTime.now()
        ..relatedEntities = _parseStringList(e['relatedEntities']);
      if (e['id'] != null) t.id = (e['id'] as num).toInt();
      return t;
    }).toList();
  }

  static List<FinanceRecord> _parseFinances(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return FinanceRecord()
        ..assetOrDebtName = e['assetOrDebtName'] as String? ?? ''
        ..amount = (e['amount'] as num?)?.toDouble() ?? 0.0
        ..isDebt = e['isDebt'] as bool? ?? false
        ..notes = e['notes'] as String?
        ..lastUpdated = DateTime.now();
    }).toList();
  }

  static List<RelationshipNode> _parseRelationships(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return RelationshipNode()
        ..personName = e['personName'] as String? ?? ''
        ..relationType = e['relationType'] as String? ?? ''
        ..trustLevel = (e['trustLevel'] as num?)?.toInt() ?? 1
        ..recentConflictOrSupport = e['recentConflictOrSupport'] as String?;
    }).toList();
  }

  static HealthProfile? _parseHealth(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return HealthProfile()
      ..conditions = _parseStringList(data['conditions'])
      ..medications = _parseStringList(data['medications'])
      ..allergies = _parseStringList(data['allergies'])
      ..bloodType = data['bloodType'] as String?
      ..labResults = _parseStringList(data['labResults'])
      ..lastUpdated = DateTime.now();
  }

  static List<Goal> _parseGoals(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      final g = Goal()
        ..title = e['title'] as String? ?? ''
        ..category = e['category'] as String? ?? 'Personal'
        ..description = e['description'] as String?
        ..targetDate = _parseDate(e['targetDate'])
        ..progress = (e['progress'] as num?)?.toInt() ?? 0
        ..isCompleted = e['isCompleted'] as bool? ?? false
        ..dateCreated = DateTime.now();
      if (e['id'] != null) g.id = (e['id'] as num).toInt();
      return g;
    }).toList();
  }

  static List<HabitVice> _parseHabitsVices(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      final hv = HabitVice()
        ..name = e['name'] as String? ?? ''
        ..isVice = e['isVice'] as bool? ?? false
        ..frequency = e['frequency'] as String? ?? 'Occasional'
        ..severity = (e['severity'] as num?)?.toInt() ?? 1
        ..notes = e['notes'] as String?
        ..dateIdentified = DateTime.now();
      if (e['id'] != null) hv.id = (e['id'] as num).toInt();
      return hv;
    }).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  static Map<String, List<CustomItem>> _parseCustomLedgers(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return {};
    final result = <String, List<CustomItem>>{};
    for (final entry in data.entries) {
      // Skip the _NOTE placeholder
      if (entry.key == '_NOTE') continue;
      if (entry.value is List) {
        result[entry.key] = (entry.value as List)
            .map((e) {
              if (e is Map<String, dynamic>) {
                return CustomItem()
                  ..name = e['name'] as String?
                  ..value = e['value'] as String?;
              }
              // Fallback: plain string becomes name
              return CustomItem()..name = e.toString();
            })
            .where((item) {
              return (item.name ?? '').isNotEmpty ||
                  (item.value ?? '').isNotEmpty;
            })
            .toList();
      }
    }
    return result;
  }

  static List<RemovalDirective> _parseRemovals(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => RemovalDirective(
            ledger: (e['ledger'] as String?)?.toLowerCase() ?? '',
            field: (e['field'] as String?)?.toLowerCase() ?? '',
            value: (e['value'] as String?) ?? '',
          ),
        )
        .where((r) => r.ledger.isNotEmpty && r.value.isNotEmpty)
        .toList();
  }

  // ── New Ledger Parsers ──

  static MedicalLedger? _parseMedical(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return MedicalLedger()
      ..surgeries = _parseStringList(data['surgeries'])
      ..genetics = _parseStringList(data['genetics'])
      ..vitalBaselines = _parseStringList(data['vitalBaselines'])
      ..visionRx = _parseStringList(data['visionRx'])
      ..familyMedicalHistory = _parseStringList(data['familyMedicalHistory'])
      ..bloodwork = _parseStringList(data['bloodwork'])
      ..immunizations = _parseStringList(data['immunizations'])
      ..dentalHistory = _parseStringList(data['dentalHistory'])
      ..lastUpdated = DateTime.now();
  }

  static CareerLedger? _parseCareer(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return CareerLedger()
      ..jobs = _parseStringList(data['jobs'])
      ..degrees = _parseStringList(data['degrees'])
      ..certifications = _parseStringList(data['certifications'])
      ..clearances = _parseStringList(data['clearances'])
      ..skills = _parseStringList(data['skills'])
      ..projects = _parseStringList(data['projects'])
      ..businesses = _parseStringList(data['businesses'])
      ..lastUpdated = DateTime.now();
  }

  static AssetLedger? _parseAssets(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return AssetLedger()
      ..realEstate = _parseStringList(data['realEstate'])
      ..vehicles = _parseStringList(data['vehicles'])
      ..digitalAssets = _parseStringList(data['digitalAssets'])
      ..insurance = _parseStringList(data['insurance'])
      ..investments = _parseStringList(data['investments'])
      ..valuables = _parseStringList(data['valuables'])
      ..equityStakes = _parseStringList(data['equityStakes'])
      ..lastUpdated = DateTime.now();
  }

  static RelationalWeb? _parseRelationalWeb(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return RelationalWeb()
      ..family = _parseStringList(data['family'])
      ..mentors = _parseStringList(data['mentors'])
      ..adversaries = _parseStringList(data['adversaries'])
      ..colleagues = _parseStringList(data['colleagues'])
      ..friends = _parseStringList(data['friends'])
      ..lastUpdated = DateTime.now();
  }

  static PsycheProfile? _parsePsyche(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return PsycheProfile()
      ..beliefs = _parseStringList(data['beliefs'])
      ..personality = _parseStringList(data['personality'])
      ..fears = _parseStringList(data['fears'])
      ..motivations = _parseStringList(data['motivations'])
      ..enneagram = data['enneagram'] as String?
      ..mbti = data['mbti'] as String?
      ..strengths = _parseStringList(data['strengths'])
      ..weaknesses = _parseStringList(data['weaknesses'])
      ..lastUpdated = DateTime.now();
  }
}

class ForgeException implements Exception {
  final String message;
  ForgeException(this.message);

  @override
  String toString() => 'ForgeException: $message';
}
