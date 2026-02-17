import 'package:isar/isar.dart';

part 'health_profile.g.dart';

/// Extra collection per agent note in Section 4.
@collection
class HealthProfile {
  Id id = Isar.autoIncrement;

  List<String>? conditions;

  List<String>? medications;

  List<String>? allergies;

  String? bloodType;

  String? primaryPhysician;

  String? insuranceInfo;

  late DateTime lastUpdated;
}
