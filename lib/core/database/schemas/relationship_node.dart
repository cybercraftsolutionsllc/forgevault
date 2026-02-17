import 'package:isar/isar.dart';

part 'relationship_node.g.dart';

@collection
class RelationshipNode {
  Id id = Isar.autoIncrement;

  late String personName;

  late String relationType;

  int trustLevel = 1; // 1-10 scale

  String? recentConflictOrSupport;
}
