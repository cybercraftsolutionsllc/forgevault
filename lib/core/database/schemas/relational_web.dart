import 'package:isar/isar.dart';

part 'relational_web.g.dart';

/// Expanded relational graph beyond RelationshipNode.
@collection
class RelationalWeb {
  Id id = Isar.autoIncrement;

  List<String>? family;

  List<String>? mentors;

  List<String>? adversaries;

  List<String>? colleagues;

  List<String>? friends;

  late DateTime lastUpdated;
}
