import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/database_service.dart';
import '../core/database/schemas/core_identity.dart';
import '../core/database/schemas/timeline_event.dart';
import '../core/database/schemas/trouble.dart';
import '../core/database/schemas/goal.dart';
import '../core/database/schemas/health_profile.dart';
import '../core/database/schemas/finance_record.dart';
import '../core/database/schemas/relationship_node.dart';
import '../core/database/schemas/habit_vice.dart';
import '../core/database/schemas/medical_ledger.dart';
import '../core/database/schemas/career_ledger.dart';
import '../core/database/schemas/asset_ledger.dart';
import '../core/database/schemas/relational_web.dart';
import '../core/database/schemas/psyche_profile.dart';
import '../core/database/schemas/custom_ledger_section.dart';
import '../core/crypto/ephemeral_key_service.dart';

/// Global provider for the database singleton.
final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider for the ephemeral encryption service (per-session).
final ephemeralKeyProvider = Provider<EphemeralKeyService>((ref) {
  return EphemeralKeyService();
});

/// Auth state — tracks whether the user has unlocked the vault.
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

/// Pro unlock state — gates Biometrics and Sync features.
final isProUnlockedProvider = StateProvider<bool>((ref) => false);

/// Selected sync directory path (held in memory, persisted via SecureStorage).
final syncDirectoryProvider = StateProvider<String?>((ref) => null);

/// Master PIN held in memory for biometric re-auth (never persisted to disk).
final masterPinProvider = StateProvider<String?>((ref) => null);

/// Current vacuum pipeline state.
enum VacuumState {
  idle,
  ingesting,
  extracting,
  forging,
  purging,
  complete,
  error,
}

final vacuumStateProvider = StateProvider<VacuumState>(
  (ref) => VacuumState.idle,
);

// ── Database Generation Counter ──
// Increment this after nuke/restore to force ALL stream providers
// to tear down old (dead) Isar streams and resubscribe to the new instance.
final dbGenerationProvider = StateProvider<int>((ref) => 0);

// ── Reactive Isar Stream Providers ──
// Each watches dbGenerationProvider so invalidation cascades correctly.

/// Watches the user's CoreIdentity (single record or null).
final identityStreamProvider = StreamProvider<CoreIdentity?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchCoreIdentity();
});

/// Watches all TimelineEvent records, sorted newest first.
final timelineStreamProvider = StreamProvider<List<TimelineEvent>>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchTimelineEvents();
});

/// Watches all Trouble records, sorted by severity.
final troublesStreamProvider = StreamProvider<List<Trouble>>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchTroubles();
});

/// Watches all Goal records.
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchGoals();
});

/// Watches the user's HealthProfile (single record or null).
final healthStreamProvider = StreamProvider<HealthProfile?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchHealthProfile();
});

/// Watches all FinanceRecord records.
final financesStreamProvider = StreamProvider<List<FinanceRecord>>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchFinanceRecords();
});

/// Watches all RelationshipNode records.
final relationshipsStreamProvider = StreamProvider<List<RelationshipNode>>((
  ref,
) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchRelationships();
});

/// Watches all HabitVice records.
final habitsStreamProvider = StreamProvider<List<HabitVice>>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchHabitsVices();
});

/// Watches MedicalLedger (single record or null).
final medicalLedgerStreamProvider = StreamProvider<MedicalLedger?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchMedicalLedger();
});

/// Watches CareerLedger (single record or null).
final careerLedgerStreamProvider = StreamProvider<CareerLedger?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchCareerLedger();
});

/// Watches AssetLedger (single record or null).
final assetLedgerStreamProvider = StreamProvider<AssetLedger?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchAssetLedger();
});

/// Watches RelationalWeb (single record or null).
final relationalWebStreamProvider = StreamProvider<RelationalWeb?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchRelationalWeb();
});

/// Watches PsycheProfile (single record or null).
final psycheProfileStreamProvider = StreamProvider<PsycheProfile?>((ref) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value(null);
  return db.watchPsycheProfile();
});

/// Bio progress (0.0–1.0) — invalidate after nuke/restore.
final bioProgressProvider = FutureProvider<double>((ref) async {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return 0.0;
  return db.calculateBioProgress();
});

/// Watches all CustomLedgerSection records.
final customLedgerSectionsProvider = StreamProvider<List<CustomLedgerSection>>((
  ref,
) {
  ref.watch(dbGenerationProvider);
  final db = ref.watch(databaseProvider);
  if (!db.isOpen) return Stream.value([]);
  return db.watchCustomLedgerSections();
});
