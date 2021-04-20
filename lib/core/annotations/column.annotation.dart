import 'package:dhis2_flutter_sdk/core/annotations/reflectable.annotation.dart';
import 'package:dhis2_flutter_sdk/core/annotations/relation.annotation.dart';
import 'package:dhis2_flutter_sdk/core/query_expression.dart';
import 'package:flutter/foundation.dart';
import 'package:reflectable/reflectable.dart';

enum ColumnType { TEXT, INTEGER, BOOLEAN }

enum RelationType { OneToMany, ManyToOne, OneToOne }

class ColumnRelation {
  final RelationType relationType;
  final String referencedTable;
  final String referencedColumn;
  ColumnRelation(
      {this.relationType, this.referencedTable, this.referencedColumn});
}

@AnnotationReflectable
class Column {
  final ColumnType type;
  final String name;
  final int length;
  final int width;
  final bool nullable;
  final bool readonly;
  final bool unique;
  final bool primary;
  final bool select;
  final bool generated;
  final ColumnRelation relation;
  const Column(
      {@required this.type,
      this.name,
      this.length = 255,
      this.width,
      this.nullable = false,
      this.readonly = false,
      this.unique = false,
      this.primary = false,
      this.select = true,
      this.generated = false,
      this.relation});

  String get columnType {
    return Column.getType(this.type);
  }

  String get columnQueryExpresion {
    return QueryExpression.getColumnExpression(
        name: this.name,
        type: this.columnType,
        primary: this.primary,
        nullable: this.nullable);
  }

  static String getType(ColumnType type) {
    switch (type) {
      case ColumnType.TEXT:
        return 'TEXT';
      case ColumnType.INTEGER:
        return 'INTEGER';
      case ColumnType.BOOLEAN:
        return 'BOOLEAN';
      default:
        return 'TEXT';
    }
  }

  static ColumnType getColumnType(Type type) {
    switch (type) {
      case String:
        return ColumnType.TEXT;
      case int:
        return ColumnType.INTEGER;
      case bool:
        return ColumnType.BOOLEAN;
      default:
        return ColumnType.TEXT;
    }
  }

  static Column getColumn(VariableMirror variableMirror, String columnName) {
    dynamic variableElement = variableMirror.metadata[0];

    if (variableElement is Column || variableElement is PrimaryColumn) {
      Column column = variableElement;
      return Column(
          type: column.type != null
              ? column.type
              : Column.getColumnType(variableMirror.reflectedType),
          name: column.name != null ? column.name : columnName,
          primary: column.primary,
          nullable: column.nullable,
          length: column.length,
          select: column.select,
          unique: column.unique);
    } else if (variableElement is ManyToOne) {
      ManyToOne manyToOneColumn = variableElement;
      return Column(
          type: ColumnType.TEXT,
          name: manyToOneColumn.joinColumnName,
          relation: ColumnRelation(
              referencedColumn: '',
              referencedTable: manyToOneColumn.parentTable,
              relationType: RelationType.ManyToOne));
    } else if (variableElement is OneToOne) {}

    return null;
  }
}

@AnnotationReflectable
class PrimaryColumn extends Column {
  const PrimaryColumn({@required ColumnType type})
      : super(type: type, primary: true);
}
