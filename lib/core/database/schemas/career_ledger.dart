import 'package:isar/isar.dart';

part 'career_ledger.g.dart';

/// Expanded career and professional development records.
@collection
class CareerLedger {
  Id id = Isar.autoIncrement;

  List<String>? jobs;

  List<String>? degrees;

  List<String>? certifications;

  List<String>? clearances;

  List<String>? skills;

  List<String>? projects;

  /// Companies owned, founder roles, board seats
  List<String>? businesses;

  late DateTime lastUpdated;
}
