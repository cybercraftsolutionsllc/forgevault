import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/database_service.dart';
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
