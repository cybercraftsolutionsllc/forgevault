import 'package:isar/isar.dart';

part 'medical_ledger.g.dart';

/// Expanded medical history beyond the base HealthProfile.
@collection
class MedicalLedger {
  Id id = Isar.autoIncrement;

  List<String>? surgeries;

  List<String>? genetics;

  List<String>? vitalBaselines;

  List<String>? visionRx;

  List<String>? familyMedicalHistory;

  List<String>? bloodwork;

  List<String>? immunizations;

  List<String>? dentalHistory;

  late DateTime lastUpdated;
}
