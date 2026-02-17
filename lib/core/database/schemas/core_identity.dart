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

  int completenessScore = 0;
}
