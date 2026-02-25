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

  List<String>? locationHistory;

  List<String>? familyLineage;

  int completenessScore = 0;

  /// Standard section titles the user has hidden from the Bio UI.
  List<String> hiddenSections = [];
}
