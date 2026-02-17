import 'package:isar/isar.dart';

part 'audit_log.g.dart';

@collection
class AuditLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;

  late String action; // "VACUUM_STARTED", "PURGE_COMPLETE", "FORGE_SYNTHESIS"

  late String fileHashDestroyed;
}
