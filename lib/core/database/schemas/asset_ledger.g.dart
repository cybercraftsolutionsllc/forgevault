// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_ledger.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssetLedgerCollection on Isar {
  IsarCollection<AssetLedger> get assetLedgers => this.collection();
}

const AssetLedgerSchema = CollectionSchema(
  name: r'AssetLedger',
  id: 2862744975720252160,
  properties: {
    r'digitalAssets': PropertySchema(
      id: 0,
      name: r'digitalAssets',
      type: IsarType.stringList,
    ),
    r'insurance': PropertySchema(
      id: 1,
      name: r'insurance',
      type: IsarType.stringList,
    ),
    r'investments': PropertySchema(
      id: 2,
      name: r'investments',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'realEstate': PropertySchema(
      id: 4,
      name: r'realEstate',
      type: IsarType.stringList,
    ),
    r'valuables': PropertySchema(
      id: 5,
      name: r'valuables',
      type: IsarType.stringList,
    ),
    r'vehicles': PropertySchema(
      id: 6,
      name: r'vehicles',
      type: IsarType.stringList,
    )
  },
  estimateSize: _assetLedgerEstimateSize,
  serialize: _assetLedgerSerialize,
  deserialize: _assetLedgerDeserialize,
  deserializeProp: _assetLedgerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _assetLedgerGetId,
  getLinks: _assetLedgerGetLinks,
  attach: _assetLedgerAttach,
  version: '3.1.0+1',
);

int _assetLedgerEstimateSize(
  AssetLedger object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.digitalAssets;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.insurance;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.investments;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.realEstate;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.valuables;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.vehicles;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  return bytesCount;
}

void _assetLedgerSerialize(
  AssetLedger object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.digitalAssets);
  writer.writeStringList(offsets[1], object.insurance);
  writer.writeStringList(offsets[2], object.investments);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeStringList(offsets[4], object.realEstate);
  writer.writeStringList(offsets[5], object.valuables);
  writer.writeStringList(offsets[6], object.vehicles);
}

AssetLedger _assetLedgerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AssetLedger();
  object.digitalAssets = reader.readStringList(offsets[0]);
  object.id = id;
  object.insurance = reader.readStringList(offsets[1]);
  object.investments = reader.readStringList(offsets[2]);
  object.lastUpdated = reader.readDateTime(offsets[3]);
  object.realEstate = reader.readStringList(offsets[4]);
  object.valuables = reader.readStringList(offsets[5]);
  object.vehicles = reader.readStringList(offsets[6]);
  return object;
}

P _assetLedgerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringList(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _assetLedgerGetId(AssetLedger object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _assetLedgerGetLinks(AssetLedger object) {
  return [];
}

void _assetLedgerAttach(
    IsarCollection<dynamic> col, Id id, AssetLedger object) {
  object.id = id;
}

extension AssetLedgerQueryWhereSort
    on QueryBuilder<AssetLedger, AssetLedger, QWhere> {
  QueryBuilder<AssetLedger, AssetLedger, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AssetLedgerQueryWhere
    on QueryBuilder<AssetLedger, AssetLedger, QWhereClause> {
  QueryBuilder<AssetLedger, AssetLedger, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AssetLedgerQueryFilter
    on QueryBuilder<AssetLedger, AssetLedger, QFilterCondition> {
  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'digitalAssets',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'digitalAssets',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'digitalAssets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'digitalAssets',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'digitalAssets',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'digitalAssets',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'digitalAssets',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      digitalAssetsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'digitalAssets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insurance',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insurance',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insurance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insurance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insurance',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insurance',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insurance',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      insuranceLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'insurance',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'investments',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'investments',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'investments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'investments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investments',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'investments',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      investmentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'investments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'realEstate',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'realEstate',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realEstate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'realEstate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'realEstate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realEstate',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'realEstate',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      realEstateLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'realEstate',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'valuables',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'valuables',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valuables',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'valuables',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'valuables',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valuables',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'valuables',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      valuablesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'valuables',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vehicles',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vehicles',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vehicles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicles',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicles',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterFilterCondition>
      vehiclesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vehicles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AssetLedgerQueryObject
    on QueryBuilder<AssetLedger, AssetLedger, QFilterCondition> {}

extension AssetLedgerQueryLinks
    on QueryBuilder<AssetLedger, AssetLedger, QFilterCondition> {}

extension AssetLedgerQuerySortBy
    on QueryBuilder<AssetLedger, AssetLedger, QSortBy> {
  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension AssetLedgerQuerySortThenBy
    on QueryBuilder<AssetLedger, AssetLedger, QSortThenBy> {
  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension AssetLedgerQueryWhereDistinct
    on QueryBuilder<AssetLedger, AssetLedger, QDistinct> {
  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByDigitalAssets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'digitalAssets');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByInsurance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insurance');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByInvestments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investments');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByRealEstate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realEstate');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByValuables() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valuables');
    });
  }

  QueryBuilder<AssetLedger, AssetLedger, QDistinct> distinctByVehicles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicles');
    });
  }
}

extension AssetLedgerQueryProperty
    on QueryBuilder<AssetLedger, AssetLedger, QQueryProperty> {
  QueryBuilder<AssetLedger, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      digitalAssetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'digitalAssets');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      insuranceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insurance');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      investmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investments');
    });
  }

  QueryBuilder<AssetLedger, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      realEstateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realEstate');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      valuablesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valuables');
    });
  }

  QueryBuilder<AssetLedger, List<String>?, QQueryOperations>
      vehiclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicles');
    });
  }
}
