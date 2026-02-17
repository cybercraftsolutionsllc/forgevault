import 'package:isar/isar.dart';

part 'habit_vice.g.dart';

/// Extra collection per agent note in Section 4.
@collection
class HabitVice {
  Id id = Isar.autoIncrement;

  late String name;

  late bool isVice; // true = vice, false = positive habit

  late String frequency; // Daily, Weekly, Occasional

  int severity = 1; // 1-10 scale (impact level)

  String? notes;

  late DateTime dateIdentified;
}
