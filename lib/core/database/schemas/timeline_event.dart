import 'package:isar/isar.dart';

part 'timeline_event.g.dart';

@collection
class TimelineEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime eventDate;

  late String title;

  late String description;

  late String category; // Health, Relationship, Career, Legal

  int emotionalImpactScore = 1; // 1-10 scale

  bool isVerified = false; // True if backed by Vacuumed document/photo
}
