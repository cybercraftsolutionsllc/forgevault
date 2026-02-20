// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relational_web.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRelationalWebCollection on Isar {
  IsarCollection<RelationalWeb> get relationalWebs => this.collection();
}

const RelationalWebSchema = CollectionSchema(
  name: r'RelationalWeb',
  id: 5068126338602979164,
  properties: {
    r'adversaries': PropertySchema(
      id: 0,
      name: r'adversaries',
      type: IsarType.stringList,
    ),
    r'colleagues': PropertySchema(
      id: 1,
      name: r'colleagues',
      type: IsarType.stringList,
    ),
    r'family': PropertySchema(
      id: 2,
      name: r'family',
      type: IsarType.stringList,
    ),
    r'friends': PropertySchema(
      id: 3,
      name: r'friends',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'mentors': PropertySchema(
      id: 5,
      name: r'mentors',
      type: IsarType.stringList,
    )
  },
  estimateSize: _relationalWebEstimateSize,
  serialize: _relationalWebSerialize,
  deserialize: _relationalWebDeserialize,
  deserializeProp: _relationalWebDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _relationalWebGetId,
  getLinks: _relationalWebGetLinks,
  attach: _relationalWebAttach,
  version: '3.1.0+1',
);

int _relationalWebEstimateSize(
  RelationalWeb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.adversaries;
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
    final list = object.colleagues;
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
    final list = object.family;
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
    final list = object.friends;
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
    final list = object.mentors;
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

void _relationalWebSerialize(
  RelationalWeb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.adversaries);
  writer.writeStringList(offsets[1], object.colleagues);
  writer.writeStringList(offsets[2], object.family);
  writer.writeStringList(offsets[3], object.friends);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeStringList(offsets[5], object.mentors);
}

RelationalWeb _relationalWebDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RelationalWeb();
  object.adversaries = reader.readStringList(offsets[0]);
  object.colleagues = reader.readStringList(offsets[1]);
  object.family = reader.readStringList(offsets[2]);
  object.friends = reader.readStringList(offsets[3]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[4]);
  object.mentors = reader.readStringList(offsets[5]);
  return object;
}

P _relationalWebDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _relationalWebGetId(RelationalWeb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _relationalWebGetLinks(RelationalWeb object) {
  return [];
}

void _relationalWebAttach(
    IsarCollection<dynamic> col, Id id, RelationalWeb object) {
  object.id = id;
}

extension RelationalWebQueryWhereSort
    on QueryBuilder<RelationalWeb, RelationalWeb, QWhere> {
  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RelationalWebQueryWhere
    on QueryBuilder<RelationalWeb, RelationalWeb, QWhereClause> {
  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterWhereClause> idBetween(
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

extension RelationalWebQueryFilter
    on QueryBuilder<RelationalWeb, RelationalWeb, QFilterCondition> {
  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'adversaries',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'adversaries',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adversaries',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'adversaries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'adversaries',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adversaries',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'adversaries',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      adversariesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'adversaries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'colleagues',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'colleagues',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colleagues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colleagues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colleagues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colleagues',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colleagues',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      colleaguesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colleagues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'family',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'family',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'family',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'family',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'family',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'family',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'family',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      familyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'family',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'friends',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'friends',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'friends',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'friends',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'friends',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'friends',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'friends',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      friendsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'friends',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
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

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mentors',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mentors',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mentors',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mentors',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mentors',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mentors',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mentors',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterFilterCondition>
      mentorsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentors',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RelationalWebQueryObject
    on QueryBuilder<RelationalWeb, RelationalWeb, QFilterCondition> {}

extension RelationalWebQueryLinks
    on QueryBuilder<RelationalWeb, RelationalWeb, QFilterCondition> {}

extension RelationalWebQuerySortBy
    on QueryBuilder<RelationalWeb, RelationalWeb, QSortBy> {
  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension RelationalWebQuerySortThenBy
    on QueryBuilder<RelationalWeb, RelationalWeb, QSortThenBy> {
  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension RelationalWebQueryWhereDistinct
    on QueryBuilder<RelationalWeb, RelationalWeb, QDistinct> {
  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct>
      distinctByAdversaries() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adversaries');
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct> distinctByColleagues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colleagues');
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct> distinctByFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'family');
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct> distinctByFriends() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'friends');
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<RelationalWeb, RelationalWeb, QDistinct> distinctByMentors() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mentors');
    });
  }
}

extension RelationalWebQueryProperty
    on QueryBuilder<RelationalWeb, RelationalWeb, QQueryProperty> {
  QueryBuilder<RelationalWeb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RelationalWeb, List<String>?, QQueryOperations>
      adversariesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adversaries');
    });
  }

  QueryBuilder<RelationalWeb, List<String>?, QQueryOperations>
      colleaguesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colleagues');
    });
  }

  QueryBuilder<RelationalWeb, List<String>?, QQueryOperations>
      familyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'family');
    });
  }

  QueryBuilder<RelationalWeb, List<String>?, QQueryOperations>
      friendsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'friends');
    });
  }

  QueryBuilder<RelationalWeb, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<RelationalWeb, List<String>?, QQueryOperations>
      mentorsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mentors');
    });
  }
}
