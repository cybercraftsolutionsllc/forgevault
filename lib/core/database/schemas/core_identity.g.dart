// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_identity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCoreIdentityCollection on Isar {
  IsarCollection<CoreIdentity> get coreIdentitys => this.collection();
}

const CoreIdentitySchema = CollectionSchema(
  name: r'CoreIdentity',
  id: 3842660777730653453,
  properties: {
    r'completenessScore': PropertySchema(
      id: 0,
      name: r'completenessScore',
      type: IsarType.long,
    ),
    r'dateOfBirth': PropertySchema(
      id: 1,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'familyLineage': PropertySchema(
      id: 2,
      name: r'familyLineage',
      type: IsarType.stringList,
    ),
    r'fullName': PropertySchema(
      id: 3,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'hiddenSections': PropertySchema(
      id: 4,
      name: r'hiddenSections',
      type: IsarType.stringList,
    ),
    r'immutableTraits': PropertySchema(
      id: 5,
      name: r'immutableTraits',
      type: IsarType.stringList,
    ),
    r'lastUpdated': PropertySchema(
      id: 6,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'location': PropertySchema(
      id: 7,
      name: r'location',
      type: IsarType.string,
    ),
    r'locationHistory': PropertySchema(
      id: 8,
      name: r'locationHistory',
      type: IsarType.stringList,
    )
  },
  estimateSize: _coreIdentityEstimateSize,
  serialize: _coreIdentitySerialize,
  deserialize: _coreIdentityDeserialize,
  deserializeProp: _coreIdentityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _coreIdentityGetId,
  getLinks: _coreIdentityGetLinks,
  attach: _coreIdentityAttach,
  version: '3.1.0+1',
);

int _coreIdentityEstimateSize(
  CoreIdentity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.familyLineage;
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
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.hiddenSections.length * 3;
  {
    for (var i = 0; i < object.hiddenSections.length; i++) {
      final value = object.hiddenSections[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final list = object.immutableTraits;
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
  bytesCount += 3 + object.location.length * 3;
  {
    final list = object.locationHistory;
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

void _coreIdentitySerialize(
  CoreIdentity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completenessScore);
  writer.writeDateTime(offsets[1], object.dateOfBirth);
  writer.writeStringList(offsets[2], object.familyLineage);
  writer.writeString(offsets[3], object.fullName);
  writer.writeStringList(offsets[4], object.hiddenSections);
  writer.writeStringList(offsets[5], object.immutableTraits);
  writer.writeDateTime(offsets[6], object.lastUpdated);
  writer.writeString(offsets[7], object.location);
  writer.writeStringList(offsets[8], object.locationHistory);
}

CoreIdentity _coreIdentityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CoreIdentity();
  object.completenessScore = reader.readLong(offsets[0]);
  object.dateOfBirth = reader.readDateTimeOrNull(offsets[1]);
  object.familyLineage = reader.readStringList(offsets[2]);
  object.fullName = reader.readString(offsets[3]);
  object.hiddenSections = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.immutableTraits = reader.readStringList(offsets[5]);
  object.lastUpdated = reader.readDateTime(offsets[6]);
  object.location = reader.readString(offsets[7]);
  object.locationHistory = reader.readStringList(offsets[8]);
  return object;
}

P _coreIdentityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _coreIdentityGetId(CoreIdentity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _coreIdentityGetLinks(CoreIdentity object) {
  return [];
}

void _coreIdentityAttach(
    IsarCollection<dynamic> col, Id id, CoreIdentity object) {
  object.id = id;
}

extension CoreIdentityQueryWhereSort
    on QueryBuilder<CoreIdentity, CoreIdentity, QWhere> {
  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CoreIdentityQueryWhere
    on QueryBuilder<CoreIdentity, CoreIdentity, QWhereClause> {
  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterWhereClause> idBetween(
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

extension CoreIdentityQueryFilter
    on QueryBuilder<CoreIdentity, CoreIdentity, QFilterCondition> {
  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      completenessScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completenessScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      completenessScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completenessScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      completenessScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completenessScore',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      completenessScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completenessScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      dateOfBirthBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfBirth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'familyLineage',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'familyLineage',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'familyLineage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'familyLineage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'familyLineage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyLineage',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'familyLineage',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      familyLineageLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyLineage',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hiddenSections',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hiddenSections',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hiddenSections',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hiddenSections',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hiddenSections',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      hiddenSectionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hiddenSections',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'immutableTraits',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'immutableTraits',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'immutableTraits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'immutableTraits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'immutableTraits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'immutableTraits',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'immutableTraits',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      immutableTraitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'immutableTraits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
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

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationHistory',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationHistory',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterFilterCondition>
      locationHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CoreIdentityQueryObject
    on QueryBuilder<CoreIdentity, CoreIdentity, QFilterCondition> {}

extension CoreIdentityQueryLinks
    on QueryBuilder<CoreIdentity, CoreIdentity, QFilterCondition> {}

extension CoreIdentityQuerySortBy
    on QueryBuilder<CoreIdentity, CoreIdentity, QSortBy> {
  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      sortByCompletenessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessScore', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      sortByCompletenessScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessScore', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }
}

extension CoreIdentityQuerySortThenBy
    on QueryBuilder<CoreIdentity, CoreIdentity, QSortThenBy> {
  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      thenByCompletenessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessScore', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      thenByCompletenessScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessScore', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QAfterSortBy> thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }
}

extension CoreIdentityQueryWhereDistinct
    on QueryBuilder<CoreIdentity, CoreIdentity, QDistinct> {
  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct>
      distinctByCompletenessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completenessScore');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct> distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct>
      distinctByFamilyLineage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'familyLineage');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct>
      distinctByHiddenSections() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hiddenSections');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct>
      distinctByImmutableTraits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'immutableTraits');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct> distinctByLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CoreIdentity, CoreIdentity, QDistinct>
      distinctByLocationHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationHistory');
    });
  }
}

extension CoreIdentityQueryProperty
    on QueryBuilder<CoreIdentity, CoreIdentity, QQueryProperty> {
  QueryBuilder<CoreIdentity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CoreIdentity, int, QQueryOperations>
      completenessScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completenessScore');
    });
  }

  QueryBuilder<CoreIdentity, DateTime?, QQueryOperations>
      dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<CoreIdentity, List<String>?, QQueryOperations>
      familyLineageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyLineage');
    });
  }

  QueryBuilder<CoreIdentity, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<CoreIdentity, List<String>, QQueryOperations>
      hiddenSectionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hiddenSections');
    });
  }

  QueryBuilder<CoreIdentity, List<String>?, QQueryOperations>
      immutableTraitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'immutableTraits');
    });
  }

  QueryBuilder<CoreIdentity, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<CoreIdentity, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<CoreIdentity, List<String>?, QQueryOperations>
      locationHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationHistory');
    });
  }
}
