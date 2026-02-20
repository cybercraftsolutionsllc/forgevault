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
    String? currentContext;
    try {
      currentContext = await _database.getBioContextString();
      if (currentContext.trim().isEmpty) currentContext = null;
    } catch (_) {
      // DB may not be ready yet — proceed without context
    }

    final prompt = ForgePrompt.buildPrompt(
      extractedText,
      existingContext: currentContext,
    );
    String rawJson;

    debugPrint(
      '\n=== CLEAN TEXT TO LLM ===\n${extractedText.substring(0, extractedText.length < 500 ? extractedText.length : 500)}...\n=========================\n',
    );

    // Priority 1: Cloud API — dynamically fetch keys from ApiKeyService.
    // A fresh instance is created every call to avoid any cached state.
    final keyService = ApiKeyService();
    final activeProvider = await keyService.getActiveProvider();

    if (activeProvider != null) {
      final key = await keyService.getApiKey(activeProvider);
      if (key != null && key.trim().isNotEmpty) {
        // If a key exists, the cloud call MUST succeed or throw the real error.
        // Do NOT silently catch and fall through — that hides HTTP failures
        // behind a false "No API Key configured" message.
        final client = ForgeApiClient(keyService: keyService);
        rawJson = await client.synthesize(extractedText);
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
    debugPrint(
      '\n=== RAW AI JSON PAYLOAD ===\n$rawJson\n===========================\n',
    );

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

      // ── Set-based merge for ALL list fields (dedup) ──
      llm.immutableTraits = <String>{
        ...?existingId.immutableTraits,
        ...?llm.immutableTraits,
      }.toList();
      llm.jobHistory = <String>{
        ...?existingId.jobHistory,
        ...?llm.jobHistory,
      }.toList();
      llm.educationHistory = <String>{
        ...?existingId.educationHistory,
        ...?llm.educationHistory,
      }.toList();
      llm.locationHistory = <String>{
        ...?existingId.locationHistory,
        ...?llm.locationHistory,
      }.toList();
      llm.familyLineage = <String>{
        ...?existingId.familyLineage,
        ...?llm.familyLineage,
      }.toList();
      llm.digitalFootprint = <String>{
        ...?existingId.digitalFootprint,
        ...?llm.digitalFootprint,
      }.toList();

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
      m.surgeries = <String>{
        ...?existingMedical.surgeries,
        ...?m.surgeries,
      }.toList();
      m.genetics = <String>{
        ...?existingMedical.genetics,
        ...?m.genetics,
      }.toList();
      m.vitalBaselines = <String>{
        ...?existingMedical.vitalBaselines,
        ...?m.vitalBaselines,
      }.toList();
      m.visionRx = <String>{
        ...?existingMedical.visionRx,
        ...?m.visionRx,
      }.toList();
      m.familyMedicalHistory = <String>{
        ...?existingMedical.familyMedicalHistory,
        ...?m.familyMedicalHistory,
      }.toList();
      m.bloodwork = <String>{
        ...?existingMedical.bloodwork,
        ...?m.bloodwork,
      }.toList();
      m.immunizations = <String>{
        ...?existingMedical.immunizations,
        ...?m.immunizations,
      }.toList();
      m.dentalHistory = <String>{
        ...?existingMedical.dentalHistory,
        ...?m.dentalHistory,
      }.toList();
    }

    // ── 8. CAREER LEDGER ALIGNMENT ──
    final existingCareer = await db.careerLedgers.where().findFirst();
    if (existingCareer != null && result.careerLedger != null) {
      final c = result.careerLedger!;
      c.id = existingCareer.id;
      c.jobs = <String>{...?existingCareer.jobs, ...?c.jobs}.toList();
      c.degrees = <String>{...?existingCareer.degrees, ...?c.degrees}.toList();
      c.certifications = <String>{
        ...?existingCareer.certifications,
        ...?c.certifications,
      }.toList();
      c.clearances = <String>{
        ...?existingCareer.clearances,
        ...?c.clearances,
      }.toList();
      c.skills = <String>{...?existingCareer.skills, ...?c.skills}.toList();
      c.projects = <String>{
        ...?existingCareer.projects,
        ...?c.projects,
      }.toList();
    }

    // ── 9. ASSET LEDGER ALIGNMENT ──
    final existingAssets = await db.assetLedgers.where().findFirst();
    if (existingAssets != null && result.assetLedger != null) {
      final a = result.assetLedger!;
      a.id = existingAssets.id;
      a.realEstate = <String>{
        ...?existingAssets.realEstate,
        ...?a.realEstate,
      }.toList();
      a.vehicles = <String>{
        ...?existingAssets.vehicles,
        ...?a.vehicles,
      }.toList();
      a.digitalAssets = <String>{
        ...?existingAssets.digitalAssets,
        ...?a.digitalAssets,
      }.toList();
      a.insurance = <String>{
        ...?existingAssets.insurance,
        ...?a.insurance,
      }.toList();
      a.investments = <String>{
        ...?existingAssets.investments,
        ...?a.investments,
      }.toList();
      a.valuables = <String>{
        ...?existingAssets.valuables,
        ...?a.valuables,
      }.toList();
    }

    // ── 10. RELATIONAL WEB ALIGNMENT ──
    final existingRelWeb = await db.relationalWebs.where().findFirst();
    if (existingRelWeb != null && result.relationalWeb != null) {
      final r = result.relationalWeb!;
      r.id = existingRelWeb.id;
      r.family = <String>{...?existingRelWeb.family, ...?r.family}.toList();
      r.mentors = <String>{...?existingRelWeb.mentors, ...?r.mentors}.toList();
      r.adversaries = <String>{
        ...?existingRelWeb.adversaries,
        ...?r.adversaries,
      }.toList();
      r.colleagues = <String>{
        ...?existingRelWeb.colleagues,
        ...?r.colleagues,
      }.toList();
      r.friends = <String>{...?existingRelWeb.friends, ...?r.friends}.toList();
    }

    // ── 11. PSYCHE PROFILE ALIGNMENT ──
    final existingPsyche = await db.psycheProfiles.where().findFirst();
    if (existingPsyche != null && result.psycheProfile != null) {
      final p = result.psycheProfile!;
      p.id = existingPsyche.id;
      p.beliefs = <String>{...?existingPsyche.beliefs, ...?p.beliefs}.toList();
      p.personality = <String>{
        ...?existingPsyche.personality,
        ...?p.personality,
      }.toList();
      p.fears = <String>{...?existingPsyche.fears, ...?p.fears}.toList();
      p.motivations = <String>{
        ...?existingPsyche.motivations,
        ...?p.motivations,
      }.toList();
      p.strengths = <String>{
        ...?existingPsyche.strengths,
        ...?p.strengths,
      }.toList();
      p.weaknesses = <String>{
        ...?existingPsyche.weaknesses,
        ...?p.weaknesses,
      }.toList();
      // Scalars: prefer new non-null values over existing
      p.enneagram ??= existingPsyche.enneagram;
      p.mbti ??= existingPsyche.mbti;
    }

    return result;
  }

  // ── Private: Database Save (simplified — IDs already aligned) ──

  Future<void> _mergeIntoDatabase(ForgeResult result) async {
    final db = _database.db;

    await db.writeTxn(() async {
      if (result.identity != null) {
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
        await db.healthProfiles.put(result.healthProfile!);
      }
      for (final goal in result.goals) {
        await db.goals.put(goal);
      }
      for (final hv in result.habitsVices) {
        await db.habitVices.put(hv);
      }
      if (result.medicalLedger != null) {
        await db.medicalLedgers.put(result.medicalLedger!);
      }
      if (result.careerLedger != null) {
        await db.careerLedgers.put(result.careerLedger!);
      }
      if (result.assetLedger != null) {
        await db.assetLedgers.put(result.assetLedger!);
      }
      if (result.relationalWeb != null) {
        await db.relationalWebs.put(result.relationalWeb!);
      }
      if (result.psycheProfile != null) {
        await db.psycheProfiles.put(result.psycheProfile!);
      }
    });
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
          ..fileHashDestroyed = 'N/A',
      );
    });
  }
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
      ..digitalFootprint = _parseStringList(data['digitalFootprint'])
      ..jobHistory = _parseStringList(data['jobHistory'])
      ..locationHistory = _parseStringList(data['locationHistory'])
      ..educationHistory = _parseStringList(data['educationHistory'])
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
