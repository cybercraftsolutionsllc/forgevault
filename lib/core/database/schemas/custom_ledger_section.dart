import 'package:isar/isar.dart';

part 'custom_ledger_section.g.dart';

/// A single key-value item within a custom ledger section.
@embedded
class CustomItem {
  String? name;
  String? value;
}

/// User-created dynamic ledger sections with key-value items.
@collection
class CustomLedgerSection {
  Id id = Isar.autoIncrement;

  late String title;

  List<CustomItem> items = [];

  late DateTime lastUpdated;
}
