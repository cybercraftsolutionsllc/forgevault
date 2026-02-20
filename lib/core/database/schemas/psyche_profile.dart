import 'package:isar/isar.dart';

part 'psyche_profile.g.dart';

/// Psychological and personality profile.
@collection
class PsycheProfile {
  Id id = Isar.autoIncrement;

  List<String>? beliefs;

  List<String>? personality;

  List<String>? fears;

  List<String>? motivations;

  String? enneagram;

  String? mbti;

  List<String>? strengths;

  List<String>? weaknesses;

  late DateTime lastUpdated;
}
