import 'package:dhis2_flutter_sdk/core/annotations/column.annotation.dart';
import 'package:dhis2_flutter_sdk/core/annotations/reflectable.annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:reflectable/reflectable.dart';

class EntityOptions {
  final String name;
  final String engine;
  final String schema;
  final bool synchronize;
  final bool withoutRowid;
  EntityOptions(
      {this.name,
      this.engine,
      this.schema,
      this.synchronize,
      this.withoutRowid});
}

@AnnotationReflectable
class Entity {
  final String tableName;
  final EntityOptions options;
  final ClassMirror classMirror;
  const Entity({@required this.tableName, this.options, this.classMirror});

  static Entity getEntityDefinition(ClassMirror entityClassMirror) {
    Entity entity = entityClassMirror.metadata != null &&
            entityClassMirror.metadata[1] is Entity
        ? entityClassMirror.metadata[1]
        : null;

    return Entity(
        tableName: entity != null && entity.tableName != null
            ? entity.tableName
            : entityClassMirror.simpleName,
        classMirror: entityClassMirror,
        options: entity != null ? entity.options : null);
  }

  static List<Column> getEntityColumns(ClassMirror entityClassMirror) {
    List<Column> columns = [];
    for (String key in entityClassMirror.superclass.declarations.keys) {
      var value = entityClassMirror.superclass.declarations[key];

      if (value is VariableMirror) {
        VariableMirror variableMirror = value;
        Column column = Column.getColumn(variableMirror, key);
        columns.add(column);
      }
    }

    for (String key in entityClassMirror.declarations.keys) {
      var value = entityClassMirror.declarations[key];
      if (value is VariableMirror) {
        VariableMirror variableMirror = value;
        Column column = Column.getColumn(variableMirror, key);
        columns.add(column);
      }
    }

    return columns;
  }
}
