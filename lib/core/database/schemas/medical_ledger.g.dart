// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_ledger.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalLedgerCollection on Isar {
  IsarCollection<MedicalLedger> get medicalLedgers => this.collection();
}

const MedicalLedgerSchema = CollectionSchema(
  name: r'MedicalLedger',
  id: 4117099871379284233,
  properties: {
    r'bloodwork': PropertySchema(
      id: 0,
      name: r'bloodwork',
      type: IsarType.stringList,
    ),
    r'dentalHistory': PropertySchema(
      id: 1,
      name: r'dentalHistory',
      type: IsarType.stringList,
    ),
    r'familyMedicalHistory': PropertySchema(
      id: 2,
      name: r'familyMedicalHistory',
      type: IsarType.stringList,
    ),
    r'genetics': PropertySchema(
      id: 3,
      name: r'genetics',
      type: IsarType.stringList,
    ),
    r'immunizations': PropertySchema(
      id: 4,
      name: r'immunizations',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 5,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'surgeries': PropertySchema(
      id: 6,
      name: r'surgeries',
      type: IsarType.stringList,
    ),
    r'visionRx': PropertySchema(
      id: 7,
      name: r'visionRx',
      type: IsarType.stringList,
    ),
    r'vitalBaselines': PropertySchema(
      id: 8,
      name: r'vitalBaselines',
      type: IsarType.stringList,
    )
  },
  estimateSize: _medicalLedgerEstimateSize,
  serialize: _medicalLedgerSerialize,
  deserialize: _medicalLedgerDeserialize,
  deserializeProp: _medicalLedgerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _medicalLedgerGetId,
  getLinks: _medicalLedgerGetLinks,
  attach: _medicalLedgerAttach,
  version: '3.1.0+1',
);

int _medicalLedgerEstimateSize(
  MedicalLedger object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.bloodwork;
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
    final list = object.dentalHistory;
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
    final list = object.familyMedicalHistory;
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
    final list = object.genetics;
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
    final list = object.immunizations;
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
    final list = object.surgeries;
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
    final list = object.visionRx;
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
    final list = object.vitalBaselines;
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

void _medicalLedgerSerialize(
  MedicalLedger object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.bloodwork);
  writer.writeStringList(offsets[1], object.dentalHistory);
  writer.writeStringList(offsets[2], object.familyMedicalHistory);
  writer.writeStringList(offsets[3], object.genetics);
  writer.writeStringList(offsets[4], object.immunizations);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeStringList(offsets[6], object.surgeries);
  writer.writeStringList(offsets[7], object.visionRx);
  writer.writeStringList(offsets[8], object.vitalBaselines);
}

MedicalLedger _medicalLedgerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalLedger();
  object.bloodwork = reader.readStringList(offsets[0]);
  object.dentalHistory = reader.readStringList(offsets[1]);
  object.familyMedicalHistory = reader.readStringList(offsets[2]);
  object.genetics = reader.readStringList(offsets[3]);
  object.id = id;
  object.immunizations = reader.readStringList(offsets[4]);
  object.lastUpdated = reader.readDateTime(offsets[5]);
  object.surgeries = reader.readStringList(offsets[6]);
  object.visionRx = reader.readStringList(offsets[7]);
  object.vitalBaselines = reader.readStringList(offsets[8]);
  return object;
}

P _medicalLedgerDeserializeProp<P>(
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
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringList(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringList(offset)) as P;
    case 7:
      return (reader.readStringList(offset)) as P;
    case 8:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicalLedgerGetId(MedicalLedger object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalLedgerGetLinks(MedicalLedger object) {
  return [];
}

void _medicalLedgerAttach(
    IsarCollection<dynamic> col, Id id, MedicalLedger object) {
  object.id = id;
}

extension MedicalLedgerQueryWhereSort
    on QueryBuilder<MedicalLedger, MedicalLedger, QWhere> {
  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicalLedgerQueryWhere
    on QueryBuilder<MedicalLedger, MedicalLedger, QWhereClause> {
  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterWhereClause> idBetween(
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

extension MedicalLedgerQueryFilter
    on QueryBuilder<MedicalLedger, MedicalLedger, QFilterCondition> {
  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodwork',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodwork',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodwork',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodwork',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodwork',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodwork',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodwork',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      bloodworkLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bloodwork',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dentalHistory',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dentalHistory',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dentalHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dentalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dentalHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dentalHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dentalHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      dentalHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dentalHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'familyMedicalHistory',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'familyMedicalHistory',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'familyMedicalHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'familyMedicalHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'familyMedicalHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyMedicalHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'familyMedicalHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      familyMedicalHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyMedicalHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genetics',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genetics',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genetics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genetics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genetics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genetics',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genetics',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      geneticsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genetics',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'immunizations',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'immunizations',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'immunizations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'immunizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'immunizations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'immunizations',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'immunizations',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      immunizationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immunizations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
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

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'surgeries',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'surgeries',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surgeries',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'surgeries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'surgeries',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surgeries',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'surgeries',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      surgeriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surgeries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visionRx',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visionRx',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visionRx',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visionRx',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visionRx',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visionRx',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visionRx',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      visionRxLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionRx',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vitalBaselines',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vitalBaselines',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vitalBaselines',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vitalBaselines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vitalBaselines',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitalBaselines',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vitalBaselines',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterFilterCondition>
      vitalBaselinesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vitalBaselines',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MedicalLedgerQueryObject
    on QueryBuilder<MedicalLedger, MedicalLedger, QFilterCondition> {}

extension MedicalLedgerQueryLinks
    on QueryBuilder<MedicalLedger, MedicalLedger, QFilterCondition> {}

extension MedicalLedgerQuerySortBy
    on QueryBuilder<MedicalLedger, MedicalLedger, QSortBy> {
  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension MedicalLedgerQuerySortThenBy
    on QueryBuilder<MedicalLedger, MedicalLedger, QSortThenBy> {
  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension MedicalLedgerQueryWhereDistinct
    on QueryBuilder<MedicalLedger, MedicalLedger, QDistinct> {
  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct> distinctByBloodwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodwork');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct>
      distinctByDentalHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dentalHistory');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct>
      distinctByFamilyMedicalHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'familyMedicalHistory');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct> distinctByGenetics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genetics');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct>
      distinctByImmunizations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'immunizations');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct> distinctBySurgeries() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surgeries');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct> distinctByVisionRx() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visionRx');
    });
  }

  QueryBuilder<MedicalLedger, MedicalLedger, QDistinct>
      distinctByVitalBaselines() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitalBaselines');
    });
  }
}

extension MedicalLedgerQueryProperty
    on QueryBuilder<MedicalLedger, MedicalLedger, QQueryProperty> {
  QueryBuilder<MedicalLedger, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      bloodworkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodwork');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      dentalHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dentalHistory');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      familyMedicalHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyMedicalHistory');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      geneticsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genetics');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      immunizationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'immunizations');
    });
  }

  QueryBuilder<MedicalLedger, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      surgeriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surgeries');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      visionRxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visionRx');
    });
  }

  QueryBuilder<MedicalLedger, List<String>?, QQueryOperations>
      vitalBaselinesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitalBaselines');
    });
  }
}
