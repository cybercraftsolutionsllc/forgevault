import 'package:isar/isar.dart';

part 'core_identity.g.dart';

@collection
class CoreIdentity {
  Id id = Isar.autoIncrement;

  late String fullName;

  DateTime? dateOfBirth;

  late String location;

  List<String>? immutableTraits;

  late DateTime lastUpdated;

  List<String>? digitalFootprint;

  List<String>? jobHistory;

  List<String>? locationHistory;

  List<String>? educationHistory;

  List<String>? familyLineage;

  int completenessScore = 0;
}
