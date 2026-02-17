// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_node.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRelationshipNodeCollection on Isar {
  IsarCollection<RelationshipNode> get relationshipNodes => this.collection();
}

const RelationshipNodeSchema = CollectionSchema(
  name: r'RelationshipNode',
  id: 1296454368234833137,
  properties: {
    r'personName': PropertySchema(
      id: 0,
      name: r'personName',
      type: IsarType.string,
    ),
    r'recentConflictOrSupport': PropertySchema(
      id: 1,
      name: r'recentConflictOrSupport',
      type: IsarType.string,
    ),
    r'relationType': PropertySchema(
      id: 2,
      name: r'relationType',
      type: IsarType.string,
    ),
    r'trustLevel': PropertySchema(
      id: 3,
      name: r'trustLevel',
      type: IsarType.long,
    )
  },
  estimateSize: _relationshipNodeEstimateSize,
  serialize: _relationshipNodeSerialize,
  deserialize: _relationshipNodeDeserialize,
  deserializeProp: _relationshipNodeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _relationshipNodeGetId,
  getLinks: _relationshipNodeGetLinks,
  attach: _relationshipNodeAttach,
  version: '3.1.0+1',
);

int _relationshipNodeEstimateSize(
  RelationshipNode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.personName.length * 3;
  {
    final value = object.recentConflictOrSupport;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.relationType.length * 3;
  return bytesCount;
}

void _relationshipNodeSerialize(
  RelationshipNode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.personName);
  writer.writeString(offsets[1], object.recentConflictOrSupport);
  writer.writeString(offsets[2], object.relationType);
  writer.writeLong(offsets[3], object.trustLevel);
}

RelationshipNode _relationshipNodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RelationshipNode();
  object.id = id;
  object.personName = reader.readString(offsets[0]);
  object.recentConflictOrSupport = reader.readStringOrNull(offsets[1]);
  object.relationType = reader.readString(offsets[2]);
  object.trustLevel = reader.readLong(offsets[3]);
  return object;
}

P _relationshipNodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _relationshipNodeGetId(RelationshipNode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _relationshipNodeGetLinks(RelationshipNode object) {
  return [];
}

void _relationshipNodeAttach(
    IsarCollection<dynamic> col, Id id, RelationshipNode object) {
  object.id = id;
}

extension RelationshipNodeQueryWhereSort
    on QueryBuilder<RelationshipNode, RelationshipNode, QWhere> {
  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RelationshipNodeQueryWhere
    on QueryBuilder<RelationshipNode, RelationshipNode, QWhereClause> {
  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterWhereClause> idBetween(
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

extension RelationshipNodeQueryFilter
    on QueryBuilder<RelationshipNode, RelationshipNode, QFilterCondition> {
  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
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

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recentConflictOrSupport',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recentConflictOrSupport',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recentConflictOrSupport',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recentConflictOrSupport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recentConflictOrSupport',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recentConflictOrSupport',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      recentConflictOrSupportIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recentConflictOrSupport',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      relationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      trustLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trustLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      trustLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trustLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      trustLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trustLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterFilterCondition>
      trustLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trustLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RelationshipNodeQueryObject
    on QueryBuilder<RelationshipNode, RelationshipNode, QFilterCondition> {}

extension RelationshipNodeQueryLinks
    on QueryBuilder<RelationshipNode, RelationshipNode, QFilterCondition> {}

extension RelationshipNodeQuerySortBy
    on QueryBuilder<RelationshipNode, RelationshipNode, QSortBy> {
  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByRecentConflictOrSupport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentConflictOrSupport', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByRecentConflictOrSupportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentConflictOrSupport', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByTrustLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustLevel', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      sortByTrustLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustLevel', Sort.desc);
    });
  }
}

extension RelationshipNodeQuerySortThenBy
    on QueryBuilder<RelationshipNode, RelationshipNode, QSortThenBy> {
  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByRecentConflictOrSupport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentConflictOrSupport', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByRecentConflictOrSupportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recentConflictOrSupport', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByTrustLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustLevel', Sort.asc);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QAfterSortBy>
      thenByTrustLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustLevel', Sort.desc);
    });
  }
}

extension RelationshipNodeQueryWhereDistinct
    on QueryBuilder<RelationshipNode, RelationshipNode, QDistinct> {
  QueryBuilder<RelationshipNode, RelationshipNode, QDistinct>
      distinctByPersonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QDistinct>
      distinctByRecentConflictOrSupport({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recentConflictOrSupport',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QDistinct>
      distinctByRelationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelationshipNode, RelationshipNode, QDistinct>
      distinctByTrustLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trustLevel');
    });
  }
}

extension RelationshipNodeQueryProperty
    on QueryBuilder<RelationshipNode, RelationshipNode, QQueryProperty> {
  QueryBuilder<RelationshipNode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RelationshipNode, String, QQueryOperations>
      personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<RelationshipNode, String?, QQueryOperations>
      recentConflictOrSupportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recentConflictOrSupport');
    });
  }

  QueryBuilder<RelationshipNode, String, QQueryOperations>
      relationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationType');
    });
  }

  QueryBuilder<RelationshipNode, int, QQueryOperations> trustLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trustLevel');
    });
  }
}
