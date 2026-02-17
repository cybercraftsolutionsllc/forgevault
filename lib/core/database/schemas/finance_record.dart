import 'package:isar/isar.dart';

part 'finance_record.g.dart';

@collection
class FinanceRecord {
  Id id = Isar.autoIncrement;

  late String assetOrDebtName;

  late double amount;

  late bool isDebt;

  String? notes;

  late DateTime lastUpdated;
}
