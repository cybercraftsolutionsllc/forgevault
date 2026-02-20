// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_ledger.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCareerLedgerCollection on Isar {
  IsarCollection<CareerLedger> get careerLedgers => this.collection();
}

const CareerLedgerSchema = CollectionSchema(
  name: r'CareerLedger',
  id: -1725444937252569597,
  properties: {
    r'certifications': PropertySchema(
      id: 0,
      name: r'certifications',
      type: IsarType.stringList,
    ),
    r'clearances': PropertySchema(
      id: 1,
      name: r'clearances',
      type: IsarType.stringList,
    ),
    r'degrees': PropertySchema(
      id: 2,
      name: r'degrees',
      type: IsarType.stringList,
    ),
    r'jobs': PropertySchema(
      id: 3,
      name: r'jobs',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'projects': PropertySchema(
      id: 5,
      name: r'projects',
      type: IsarType.stringList,
    ),
    r'skills': PropertySchema(
      id: 6,
      name: r'skills',
      type: IsarType.stringList,
    )
  },
  estimateSize: _careerLedgerEstimateSize,
  serialize: _careerLedgerSerialize,
  deserialize: _careerLedgerDeserialize,
  deserializeProp: _careerLedgerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _careerLedgerGetId,
  getLinks: _careerLedgerGetLinks,
  attach: _careerLedgerAttach,
  version: '3.1.0+1',
);

int _careerLedgerEstimateSize(
  CareerLedger object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.certifications;
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
    final list = object.clearances;
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
    final list = object.degrees;
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
    final list = object.jobs;
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
    final list = object.projects;
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
    final list = object.skills;
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

void _careerLedgerSerialize(
  CareerLedger object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.certifications);
  writer.writeStringList(offsets[1], object.clearances);
  writer.writeStringList(offsets[2], object.degrees);
  writer.writeStringList(offsets[3], object.jobs);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeStringList(offsets[5], object.projects);
  writer.writeStringList(offsets[6], object.skills);
}

CareerLedger _careerLedgerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CareerLedger();
  object.certifications = reader.readStringList(offsets[0]);
  object.clearances = reader.readStringList(offsets[1]);
  object.degrees = reader.readStringList(offsets[2]);
  object.id = id;
  object.jobs = reader.readStringList(offsets[3]);
  object.lastUpdated = reader.readDateTime(offsets[4]);
  object.projects = reader.readStringList(offsets[5]);
  object.skills = reader.readStringList(offsets[6]);
  return object;
}

P _careerLedgerDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _careerLedgerGetId(CareerLedger object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _careerLedgerGetLinks(CareerLedger object) {
  return [];
}

void _careerLedgerAttach(
    IsarCollection<dynamic> col, Id id, CareerLedger object) {
  object.id = id;
}

extension CareerLedgerQueryWhereSort
    on QueryBuilder<CareerLedger, CareerLedger, QWhere> {
  QueryBuilder<CareerLedger, CareerLedger, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CareerLedgerQueryWhere
    on QueryBuilder<CareerLedger, CareerLedger, QWhereClause> {
  QueryBuilder<CareerLedger, CareerLedger, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterWhereClause> idBetween(
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

extension CareerLedgerQueryFilter
    on QueryBuilder<CareerLedger, CareerLedger, QFilterCondition> {
  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certifications',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certifications',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'certifications',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certifications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certifications',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certifications',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certifications',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      certificationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'certifications',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clearances',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clearances',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clearances',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clearances',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clearances',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clearances',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clearances',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      clearancesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clearances',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'degrees',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'degrees',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'degrees',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'degrees',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'degrees',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'degrees',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'degrees',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      degreesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'degrees',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition> jobsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jobs',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jobs',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jobs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jobs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jobs',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jobs',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jobs',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      jobsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jobs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
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

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'projects',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'projects',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projects',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projects',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projects',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projects',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      projectsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'projects',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'skills',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'skills',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skills',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'skills',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'skills',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skills',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'skills',
        value: '',
      ));
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterFilterCondition>
      skillsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skills',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CareerLedgerQueryObject
    on QueryBuilder<CareerLedger, CareerLedger, QFilterCondition> {}

extension CareerLedgerQueryLinks
    on QueryBuilder<CareerLedger, CareerLedger, QFilterCondition> {}

extension CareerLedgerQuerySortBy
    on QueryBuilder<CareerLedger, CareerLedger, QSortBy> {
  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension CareerLedgerQuerySortThenBy
    on QueryBuilder<CareerLedger, CareerLedger, QSortThenBy> {
  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension CareerLedgerQueryWhereDistinct
    on QueryBuilder<CareerLedger, CareerLedger, QDistinct> {
  QueryBuilder<CareerLedger, CareerLedger, QDistinct>
      distinctByCertifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certifications');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctByClearances() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clearances');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctByDegrees() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'degrees');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctByJobs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobs');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctByProjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projects');
    });
  }

  QueryBuilder<CareerLedger, CareerLedger, QDistinct> distinctBySkills() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skills');
    });
  }
}

extension CareerLedgerQueryProperty
    on QueryBuilder<CareerLedger, CareerLedger, QQueryProperty> {
  QueryBuilder<CareerLedger, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations>
      certificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certifications');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations>
      clearancesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clearances');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations>
      degreesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'degrees');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations> jobsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobs');
    });
  }

  QueryBuilder<CareerLedger, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations>
      projectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projects');
    });
  }

  QueryBuilder<CareerLedger, List<String>?, QQueryOperations> skillsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skills');
    });
  }
}
