import 'package:dhis2_flutter_sdk/d2_touch.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/entities/user.entity.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/queries/user.query.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/entities/program_stage.entity.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/queries/program_stage.query.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'program_stage_sync_test.reflectable.dart';
import '../sample/current_user.sample.dart';
import '../sample/program_stage.sample.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  initializeReflectable();
  sqfliteFfiInit();

  var databaseFactory = databaseFactoryFfi;

  await D2Touch.initialize(
      databaseFactory: databaseFactoryFfi, databaseName: 'flutter_test');

  var db = await databaseFactory.openDatabase(inMemoryDatabasePath);

  UserQuery userQuery = UserQuery(database: db);

  final dio = Dio(BaseOptions());
  final dioAdapter = DioAdapter(dio: dio);

  dioAdapter.onGet(
    'https://play.dhis2.org/2.35.11/api/programStages.json?fields=id,name,displayName,shortName,lastUpdated,created,code,dirty,sortOrder,executionDateLabel,description,formType,blockEntryForm,hideDueDate,repeatable,allowGenerateNextVisit,minDaysFromStart,generatedByEnrollmentDate,autoGenerateEvent,captureCoordinates,featureType,dueDateLabel,programStageSections[id,name,displayName,shortName,lastUpdated,created,code,dirty,programStage],program,programStageDataElements[id,name,displayName,shortName,lastUpdated,created,code,dirty,formName,valueType,dataElementId,aggregationType,domainType,description,displayDescription,displayFormName,displayInReports,renderOptionsAsRadio,compulsory,sortOrder,skipSynchronization,allowFutureDate,zeroIsSignificant,periodOffset,programStage,optionSetValue,optionSetName,options[id,name,displayName,shortName,lastUpdated,created,code,dirty,programStageDataElement]]&paging=false',
    (server) => server.reply(200, sampleProgramStages),
  );

  userData['password'] = 'district';
  userData['isLoggedIn'] = true;
  userData['username'] = 'admin';
  userData['baseUrl'] = 'https://play.dhis2.org/2.35.11';
  final user = User.fromApi(userData);
  await userQuery.setData(user).save();
  final programStageQuery = ProgramStageQuery(database: db);

  await programStageQuery.download((progress, complete) {
    print(progress.message);
  }, dioTestClient: dio);

  List<ProgramStage> programStages = await programStageQuery.get();

  test('should download and store all incoming program stage metadata', () {
    expect(programStages.length, 2);
  });
}
