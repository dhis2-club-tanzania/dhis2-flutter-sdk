import 'package:dhis2_flutter_sdk/core/annotations/index.dart';
import 'package:dhis2_flutter_sdk/core/utilities/repository.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/entities/user.entity.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/entities/user_authority.entity.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/entities/user_organisation_unit.entity.dart';
import 'package:dhis2_flutter_sdk/shared/queries/base.query.dart';
import 'package:reflectable/reflectable.dart';
import 'package:sqflite/sqflite.dart';

class UserQuery extends BaseQuery<User> {
  UserQuery({Database? database}) : super(database: database);

  UserQuery withOrganisationUnit() {
    final userOrganisationUnit = Repository<UserOrganisationUnit>();
    final Column? relationColumn = userOrganisationUnit.columns.firstWhere(
        (column) =>
            column.relation?.referencedEntity?.tableName == this.tableName);

    if (relationColumn != null) {
      ColumnRelation relation = ColumnRelation(
          referencedColumn: relationColumn.relation?.attributeName,
          attributeName: 'organisationUnits',
          primaryKey: this.primaryKey?.name,
          relationType: RelationType.OneToMany,
          referencedEntity: Entity.getEntityDefinition(
              AnnotationReflectable.reflectType(UserOrganisationUnit)
                  as ClassMirror),
          referencedEntityColumns: Entity.getEntityColumns(
              AnnotationReflectable.reflectType(UserOrganisationUnit)
                  as ClassMirror,
              false));
      this.relations.add(relation);
    }

    return this;
  }

  UserQuery withAuthorities() {
    final userAuthority = Repository<UserAuthority>();
    final Column? relationColumn = userAuthority.columns.firstWhere((column) =>
        column.relation?.referencedEntity?.tableName == this.tableName);

    if (relationColumn != null) {
      ColumnRelation relation = ColumnRelation(
          referencedColumn: relationColumn.relation?.attributeName,
          attributeName: 'authorities',
          primaryKey: this.primaryKey?.name,
          relationType: RelationType.OneToMany,
          referencedEntity: Entity.getEntityDefinition(
              AnnotationReflectable.reflectType(UserAuthority) as ClassMirror),
          referencedEntityColumns: Entity.getEntityColumns(
              AnnotationReflectable.reflectType(UserAuthority) as ClassMirror,
              false));
      this.relations.add(relation);
    }

    return this;
  }
}
