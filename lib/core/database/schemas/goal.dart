import 'package:isar/isar.dart';

part 'goal.g.dart';

/// Extra collection per agent note in Section 4.
@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String title;

  late String category; // Career, Health, Financial, Personal

  String? description;

  DateTime? targetDate;

  int progress = 0; // 0-100

  bool isCompleted = false;

  late DateTime dateCreated;
}
