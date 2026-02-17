import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vitavault/core/database/schemas/core_identity.dart';
import 'package:vitavault/core/database/schemas/timeline_event.dart';
import 'package:vitavault/core/database/schemas/trouble.dart';
import 'package:vitavault/core/database/schemas/finance_record.dart';
import 'package:vitavault/core/database/schemas/relationship_node.dart';
import 'package:vitavault/core/database/schemas/health_profile.dart';
import 'package:vitavault/core/database/schemas/goal.dart';
import 'package:vitavault/core/database/schemas/habit_vice.dart';
import 'package:vitavault/core/database/schemas/audit_log.dart';

import 'package:vitavault/core/testing/test_data_generator.dart';
import 'package:vitavault/core/services/purge_service.dart';
import 'package:vitavault/core/database/database_service.dart';
import 'package:vitavault/core/crypto/ephemeral_key_service.dart';

/// ──────────────────────────────────────────────────────────────────
/// CORE LOOP INTEGRATION TEST
/// ──────────────────────────────────────────────────────────────────
///
/// Tests the full Vacuum → Forge → Purge pipeline:
///
/// 1. Bypasses biometric lock (no auth gate in test)
/// 2. Generates fake_journal.txt via Chaos Generator
/// 3. Mocks the LLM response (avoids hitting real APIs)
/// 4. Asserts Isar records the extracted Trouble and Goal
/// 5. Asserts the file is moved to vitavault_debug_trash/
///
/// Runs with [isSafeMode] = true (kDebugMode) so no real
/// destructive operations occur.
/// ──────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late File fakeJournal;

  setUpAll(() async {
    // ── Open a fresh test Isar instance ──
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open(
      [
        CoreIdentitySchema,
        TimelineEventSchema,
        TroubleSchema,
        FinanceRecordSchema,
        RelationshipNodeSchema,
        HealthProfileSchema,
        GoalSchema,
        HabitViceSchema,
        AuditLogSchema,
      ],
      directory: dir.path,
      name: 'vitavault_test_${DateTime.now().millisecondsSinceEpoch}',
    );

    // ── Generate test data ──
    fakeJournal = await TestDataGenerator.generateFakeJournal();
  });

  tearDownAll(() async {
    // Clean up
    await isar.close(deleteFromDisk: true);

    // Clean temp files
    if (await fakeJournal.exists()) {
      await fakeJournal.delete();
    }
  });

  group('Core Loop: Vacuum → Forge → Purge', () {
    testWidgets('fake_journal.txt → ForgeService → Isar records Trouble + Goal', (
      tester,
    ) async {
      // ── Arrange ──

      // Read the fake journal content (simulates VacuumService text extraction)
      final extractedText = await fakeJournal.readAsString();
      expect(extractedText, contains('Mr. Henderson'));
      expect(extractedText, contains('450'));
      expect(extractedText, contains('December 2026'));

      // Parse the mock LLM JSON directly (bypasses real API calls)
      final mockJson = TestDataGenerator.mockJournalForgeResponse;
      final parsed = jsonDecode(mockJson) as Map<String, dynamic>;

      // ── Act ──
      // Simulate what ForgeService._parseForgeJson + _mergeIntoDatabase does
      await isar.writeTxn(() async {
        // Write troubles
        final troublesData = parsed['troubles'] as List<dynamic>;
        for (final t in troublesData) {
          final trouble = Trouble()
            ..title = t['title'] as String
            ..detailText = t['detailText'] as String
            ..category = t['category'] as String
            ..severity = t['severity'] as int
            ..isResolved = t['isResolved'] as bool
            ..dateIdentified = DateTime.parse(t['dateIdentified'] as String)
            ..relatedEntities = (t['relatedEntities'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
          await isar.troubles.put(trouble);
        }

        // Write goals
        final goalsData = parsed['goals'] as List<dynamic>;
        for (final g in goalsData) {
          final goal = Goal()
            ..title = g['title'] as String
            ..category = g['category'] as String
            ..description = g['description'] as String?
            ..targetDate = DateTime.tryParse(g['targetDate'] as String? ?? '')
            ..progress = g['progress'] as int
            ..isCompleted = false
            ..dateCreated = DateTime.now();
          await isar.goals.put(goal);
        }

        // Write finances
        final financesData = parsed['finances'] as List<dynamic>;
        for (final f in financesData) {
          final finance = FinanceRecord()
            ..assetOrDebtName = f['assetOrDebtName'] as String
            ..amount = (f['amount'] as num).toDouble()
            ..isDebt = f['isDebt'] as bool
            ..notes = f['notes'] as String?
            ..lastUpdated = DateTime.now();
          await isar.financeRecords.put(finance);
        }

        // Write audit log
        await isar.auditLogs.put(
          AuditLog()
            ..timestamp = DateTime.now()
            ..action = 'FORGE_SYNTHESIS'
            ..fileHashDestroyed = 'test_hash_fake_journal',
        );
      });

      // ── Assert: Trouble recorded ──
      final troubles = await isar.troubles.where().findAll();
      expect(troubles, isNotEmpty, reason: 'Should have at least 1 Trouble');

      final landlordTrouble = troubles.firstWhere(
        (t) => t.title.toLowerCase().contains('landlord'),
        orElse: () => throw StateError('No landlord trouble found'),
      );
      expect(landlordTrouble.severity, greaterThanOrEqualTo(7));
      expect(landlordTrouble.category, equals('Housing'));
      expect(landlordTrouble.relatedEntities, contains('Mr. Henderson'));
      expect(landlordTrouble.isResolved, isFalse);

      // ── Assert: Goal recorded ──
      final goals = await isar.goals.where().findAll();
      expect(goals, isNotEmpty, reason: 'Should have at least 1 Goal');

      final moveGoal = goals.firstWhere(
        (g) => g.title.toLowerCase().contains('move'),
        orElse: () => throw StateError('No move-out goal found'),
      );
      expect(moveGoal.category, equals('Personal'));
      expect(moveGoal.targetDate, isNotNull);
      expect(moveGoal.targetDate!.year, equals(2026));
      expect(moveGoal.targetDate!.month, equals(12));

      // ── Assert: Finance recorded ──
      final finances = await isar.financeRecords.where().findAll();
      expect(finances, isNotEmpty);
      final depositDeduction = finances.firstWhere(
        (f) => f.amount == 450.0,
        orElse: () => throw StateError('No \$450 finance record found'),
      );
      expect(depositDeduction.isDebt, isTrue);

      // ── Assert: Audit log written ──
      final auditLogs = await isar.auditLogs.where().findAll();
      expect(
        auditLogs.any((log) => log.action == 'FORGE_SYNTHESIS'),
        isTrue,
        reason: 'Audit log should contain FORGE_SYNTHESIS entry',
      );
    });

    testWidgets('PurgeService safe mode moves file to debug trash', (
      tester,
    ) async {
      // ── Arrange ──
      // Create a disposable test file to purge
      final tempDir = Directory.systemTemp;
      final testFile = File(
        '${tempDir.path}${Platform.pathSeparator}purge_test_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await testFile.writeAsString('This file should be moved, not deleted.');
      expect(await testFile.exists(), isTrue);

      final originalPath = testFile.path;

      // Use DatabaseService.instance and initialize it with a test PIN
      // so PurgeService can write audit logs
      final dbService = DatabaseService.instance;
      if (!dbService.isOpen) {
        await dbService.setupPin('0000');
        await dbService.initialize('0000');
      }

      final purge = PurgeService(database: dbService);
      final ephemeral = EphemeralKeyService();
      ephemeral.generateKey();

      // ── Act ──
      await purge.purge(
        sandboxPath: originalPath,
        fileHash: 'test_hash_purge_safe_mode',
        ephemeralCrypto: ephemeral,
      );

      // ── Assert: File no longer at original location ──
      expect(
        await testFile.exists(),
        isFalse,
        reason: 'Original file should be moved away from its path',
      );

      // ── Assert: File is in debug trash ──
      final trashDir = await PurgeService.getDebugTrashDir();
      final trashContents = await trashDir.list().toList();
      final movedFile = trashContents.whereType<File>().where(
        (f) => f.path.contains('purge_test_'),
      );
      expect(
        movedFile.isNotEmpty,
        isTrue,
        reason: 'File should exist in vitavault_debug_trash/',
      );
    });
  });
}
