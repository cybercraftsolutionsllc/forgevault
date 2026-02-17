import 'package:isar/isar.dart';

part 'trouble.g.dart';

@collection
class Trouble {
  Id id = Isar.autoIncrement;

  late String title;

  late String detailText;

  late String category;

  int severity = 1; // 1-10 scale

  bool isResolved = false;

  late DateTime dateIdentified;

  List<String>? relatedEntities;
}
