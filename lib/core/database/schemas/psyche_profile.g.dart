// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'psyche_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPsycheProfileCollection on Isar {
  IsarCollection<PsycheProfile> get psycheProfiles => this.collection();
}

const PsycheProfileSchema = CollectionSchema(
  name: r'PsycheProfile',
  id: -6728961493590466213,
  properties: {
    r'beliefs': PropertySchema(
      id: 0,
      name: r'beliefs',
      type: IsarType.stringList,
    ),
    r'enneagram': PropertySchema(
      id: 1,
      name: r'enneagram',
      type: IsarType.string,
    ),
    r'fears': PropertySchema(
      id: 2,
      name: r'fears',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'mbti': PropertySchema(
      id: 4,
      name: r'mbti',
      type: IsarType.string,
    ),
    r'motivations': PropertySchema(
      id: 5,
      name: r'motivations',
      type: IsarType.stringList,
    ),
    r'personality': PropertySchema(
      id: 6,
      name: r'personality',
      type: IsarType.stringList,
    ),
    r'strengths': PropertySchema(
      id: 7,
      name: r'strengths',
      type: IsarType.stringList,
    ),
    r'weaknesses': PropertySchema(
      id: 8,
      name: r'weaknesses',
      type: IsarType.stringList,
    )
  },
  estimateSize: _psycheProfileEstimateSize,
  serialize: _psycheProfileSerialize,
  deserialize: _psycheProfileDeserialize,
  deserializeProp: _psycheProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _psycheProfileGetId,
  getLinks: _psycheProfileGetLinks,
  attach: _psycheProfileAttach,
  version: '3.1.0+1',
);

int _psycheProfileEstimateSize(
  PsycheProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.beliefs;
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
    final value = object.enneagram;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.fears;
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
    final value = object.mbti;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.motivations;
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
    final list = object.personality;
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
    final list = object.strengths;
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
    final list = object.weaknesses;
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

void _psycheProfileSerialize(
  PsycheProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.beliefs);
  writer.writeString(offsets[1], object.enneagram);
  writer.writeStringList(offsets[2], object.fears);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeString(offsets[4], object.mbti);
  writer.writeStringList(offsets[5], object.motivations);
  writer.writeStringList(offsets[6], object.personality);
  writer.writeStringList(offsets[7], object.strengths);
  writer.writeStringList(offsets[8], object.weaknesses);
}

PsycheProfile _psycheProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PsycheProfile();
  object.beliefs = reader.readStringList(offsets[0]);
  object.enneagram = reader.readStringOrNull(offsets[1]);
  object.fears = reader.readStringList(offsets[2]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[3]);
  object.mbti = reader.readStringOrNull(offsets[4]);
  object.motivations = reader.readStringList(offsets[5]);
  object.personality = reader.readStringList(offsets[6]);
  object.strengths = reader.readStringList(offsets[7]);
  object.weaknesses = reader.readStringList(offsets[8]);
  return object;
}

P _psycheProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
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

Id _psycheProfileGetId(PsycheProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _psycheProfileGetLinks(PsycheProfile object) {
  return [];
}

void _psycheProfileAttach(
    IsarCollection<dynamic> col, Id id, PsycheProfile object) {
  object.id = id;
}

extension PsycheProfileQueryWhereSort
    on QueryBuilder<PsycheProfile, PsycheProfile, QWhere> {
  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PsycheProfileQueryWhere
    on QueryBuilder<PsycheProfile, PsycheProfile, QWhereClause> {
  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterWhereClause> idBetween(
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

extension PsycheProfileQueryFilter
    on QueryBuilder<PsycheProfile, PsycheProfile, QFilterCondition> {
  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'beliefs',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'beliefs',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'beliefs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'beliefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'beliefs',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beliefs',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'beliefs',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      beliefsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'beliefs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'enneagram',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'enneagram',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enneagram',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enneagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enneagram',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enneagram',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      enneagramIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enneagram',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fears',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fears',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fears',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fears',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fears',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fears',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fears',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      fearsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fears',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
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

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mbti',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mbti',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> mbtiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> mbtiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mbti',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mbti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition> mbtiMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mbti',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mbti',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      mbtiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mbti',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motivations',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motivations',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motivations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motivations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motivations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motivations',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motivations',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      motivationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'motivations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'personality',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'personality',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personality',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personality',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      personalityLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'strengths',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'strengths',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'strengths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'strengths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strengths',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'strengths',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      strengthsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'strengths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weaknesses',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weaknesses',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weaknesses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weaknesses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weaknesses',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weaknesses',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weaknesses',
        value: '',
      ));
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterFilterCondition>
      weaknessesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weaknesses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PsycheProfileQueryObject
    on QueryBuilder<PsycheProfile, PsycheProfile, QFilterCondition> {}

extension PsycheProfileQueryLinks
    on QueryBuilder<PsycheProfile, PsycheProfile, QFilterCondition> {}

extension PsycheProfileQuerySortBy
    on QueryBuilder<PsycheProfile, PsycheProfile, QSortBy> {
  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> sortByEnneagram() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enneagram', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy>
      sortByEnneagramDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enneagram', Sort.desc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> sortByMbti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mbti', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> sortByMbtiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mbti', Sort.desc);
    });
  }
}

extension PsycheProfileQuerySortThenBy
    on QueryBuilder<PsycheProfile, PsycheProfile, QSortThenBy> {
  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenByEnneagram() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enneagram', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy>
      thenByEnneagramDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enneagram', Sort.desc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenByMbti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mbti', Sort.asc);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QAfterSortBy> thenByMbtiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mbti', Sort.desc);
    });
  }
}

extension PsycheProfileQueryWhereDistinct
    on QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> {
  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByBeliefs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beliefs');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByEnneagram(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enneagram', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByFears() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fears');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByMbti(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mbti', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct>
      distinctByMotivations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motivations');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct>
      distinctByPersonality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personality');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByStrengths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strengths');
    });
  }

  QueryBuilder<PsycheProfile, PsycheProfile, QDistinct> distinctByWeaknesses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weaknesses');
    });
  }
}

extension PsycheProfileQueryProperty
    on QueryBuilder<PsycheProfile, PsycheProfile, QQueryProperty> {
  QueryBuilder<PsycheProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations>
      beliefsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beliefs');
    });
  }

  QueryBuilder<PsycheProfile, String?, QQueryOperations> enneagramProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enneagram');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations> fearsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fears');
    });
  }

  QueryBuilder<PsycheProfile, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<PsycheProfile, String?, QQueryOperations> mbtiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mbti');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations>
      motivationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motivations');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations>
      personalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personality');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations>
      strengthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strengths');
    });
  }

  QueryBuilder<PsycheProfile, List<String>?, QQueryOperations>
      weaknessesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weaknesses');
    });
  }
}
