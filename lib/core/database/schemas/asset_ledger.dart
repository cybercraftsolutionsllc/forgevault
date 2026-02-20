import 'package:isar/isar.dart';

part 'asset_ledger.g.dart';

/// Tangible and digital asset tracking.
@collection
class AssetLedger {
  Id id = Isar.autoIncrement;

  List<String>? realEstate;

  List<String>? vehicles;

  List<String>? digitalAssets;

  List<String>? insurance;

  List<String>? investments;

  List<String>? valuables;

  late DateTime lastUpdated;
}
