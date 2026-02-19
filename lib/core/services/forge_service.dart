import 'dart:convert';
import 'dart:io';

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
        return _parseForgeJson(rawJson);
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
        return _parseForgeJson(rawJson);
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

  // ── Private: Database Merge ──

  Future<void> _mergeIntoDatabase(ForgeResult result) async {
    final db = _database.db;

    // Prefetch existing records BEFORE entering writeTxn
    // (Isar doesn't support read queries inside write transactions)
    final existingIdentity = await db.coreIdentitys.where().findFirst();
    final existingHealth = await db.healthProfiles.where().findFirst();
    final allTroubles = await db.troubles.where().findAll();
    final allGoals = await db.goals.where().findAll();
    final allHV = await db.habitVices.where().findAll();

    // Align IDs before writing
    if (result.identity != null && existingIdentity != null) {
      result.identity!.id = existingIdentity.id;
    }
    if (result.healthProfile != null && existingHealth != null) {
      result.healthProfile!.id = existingHealth.id;
    }
    for (final trouble in result.troubles) {
      final match = allTroubles
          .where((t) => t.title == trouble.title)
          .firstOrNull;
      if (match != null) trouble.id = match.id;
    }
    for (final goal in result.goals) {
      final match = allGoals.where((g) => g.title == goal.title).firstOrNull;
      if (match != null) goal.id = match.id;
    }
    for (final hv in result.habitsVices) {
      final match = allHV.where((h) => h.name == hv.name).firstOrNull;
      if (match != null) hv.id = match.id;
    }

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
    });
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
  List<String> contradictions;

  ForgeResult({
    this.identity,
    this.timelineEvents = const [],
    this.troubles = const [],
    this.finances = const [],
    this.relationships = const [],
    this.healthProfile,
    this.goals = const [],
    this.habitsVices = const [],
    this.contradictions = const [],
  });

  factory ForgeResult.fromJson(Map<String, dynamic> json) {
    return ForgeResult(
      identity: _parseIdentity(json['identity']),
      timelineEvents: _parseTimelineEvents(json['timelineEvents']),
      troubles: _parseTroubles(json['troubles']),
      finances: _parseFinances(json['finances']),
      relationships: _parseRelationships(json['relationships']),
      healthProfile: _parseHealth(json['health']),
      goals: _parseGoals(json['goals']),
      habitsVices: _parseHabitsVices(json['habitsVices']),
      contradictions: _parseStringList(json['contradictions']),
    );
  }

  // ── Parsers ──

  static CoreIdentity? _parseIdentity(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return CoreIdentity()
      ..fullName = data['fullName'] as String? ?? 'Unknown'
      ..dateOfBirth = _parseDate(data['dateOfBirth'])
      ..location = data['location'] as String? ?? ''
      ..immutableTraits = _parseStringList(data['immutableTraits'])
      ..lastUpdated = DateTime.now()
      ..completenessScore = 0;
  }

  static List<TimelineEvent> _parseTimelineEvents(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return TimelineEvent()
        ..eventDate = _parseDate(e['eventDate']) ?? DateTime.now()
        ..title = e['title'] as String? ?? ''
        ..description = e['description'] as String? ?? ''
        ..category = e['category'] as String? ?? 'Personal'
        ..emotionalImpactScore =
            (e['emotionalImpactScore'] as num?)?.toInt() ?? 1
        ..isVerified = e['isVerified'] as bool? ?? false;
    }).toList();
  }

  static List<Trouble> _parseTroubles(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return Trouble()
        ..title = e['title'] as String? ?? ''
        ..detailText = e['detailText'] as String? ?? ''
        ..category = e['category'] as String? ?? ''
        ..severity = (e['severity'] as num?)?.toInt() ?? 1
        ..isResolved = e['isResolved'] as bool? ?? false
        ..dateIdentified = _parseDate(e['dateIdentified']) ?? DateTime.now()
        ..relatedEntities = _parseStringList(e['relatedEntities']);
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
      ..lastUpdated = DateTime.now();
  }

  static List<Goal> _parseGoals(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return Goal()
        ..title = e['title'] as String? ?? ''
        ..category = e['category'] as String? ?? 'Personal'
        ..description = e['description'] as String?
        ..targetDate = _parseDate(e['targetDate'])
        ..progress = (e['progress'] as num?)?.toInt() ?? 0
        ..isCompleted = false
        ..dateCreated = DateTime.now();
    }).toList();
  }

  static List<HabitVice> _parseHabitsVices(dynamic data) {
    if (data == null || data is! List) return [];
    return data.cast<Map<String, dynamic>>().map((e) {
      return HabitVice()
        ..name = e['name'] as String? ?? ''
        ..isVice = e['isVice'] as bool? ?? false
        ..frequency = e['frequency'] as String? ?? 'Occasional'
        ..severity = (e['severity'] as num?)?.toInt() ?? 1
        ..notes = e['notes'] as String?
        ..dateIdentified = DateTime.now();
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
}

class ForgeException implements Exception {
  final String message;
  ForgeException(this.message);

  @override
  String toString() => 'ForgeException: $message';
}
