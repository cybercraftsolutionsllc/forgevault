import 'package:isar/isar.dart';

part 'audit_log.g.dart';

/// Tracks user-visible audit events: document ingestion, manual edits,
/// purge operations, and synthesis runs.
@collection
class AuditLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;

  late String action; // "Ingestion Complete", "Manual Vault Edit", "Purge"

  String details = ''; // Human-readable summary of what happened

  String? aiSummary; // AI-generated receipt: what was extracted vs skipped
}
