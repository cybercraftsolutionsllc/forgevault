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

// ── Reactive Isar Stream Providers ──
// These fire immediately and update whenever the database is mutated.

/// Watches the user's CoreIdentity (single record or null).
final identityStreamProvider = StreamProvider<CoreIdentity?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCoreIdentity();
});

/// Watches all TimelineEvent records, sorted newest first.
final timelineStreamProvider = StreamProvider<List<TimelineEvent>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTimelineEvents();
});

/// Watches all Trouble records, sorted by severity.
final troublesStreamProvider = StreamProvider<List<Trouble>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTroubles();
});

/// Watches all Goal records.
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchGoals();
});

/// Watches the user's HealthProfile (single record or null).
final healthStreamProvider = StreamProvider<HealthProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchHealthProfile();
});

/// Watches all FinanceRecord records.
final financesStreamProvider = StreamProvider<List<FinanceRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchFinanceRecords();
});

/// Watches all RelationshipNode records.
final relationshipsStreamProvider = StreamProvider<List<RelationshipNode>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db.watchRelationships();
});

/// Watches all HabitVice records.
final habitsStreamProvider = StreamProvider<List<HabitVice>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchHabitsVices();
});
