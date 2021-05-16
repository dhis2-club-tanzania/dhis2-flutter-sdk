import 'package:dhis2_flutter_sdk/d2_touch.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/entities/program.entity.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/entities/program_stage.entity.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/queries/program.query.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/queries/program_stage.query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'program_module_test.reflectable.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  initializeReflectable();
  sqfliteFfiInit();

  await D2Touch.initialize(
      databaseFactory: databaseFactoryFfi, databaseName: 'flutter_test');

  ProgramQuery programQuery = D2Touch.programModule.program;
  ProgramStageQuery programStageQuery = D2Touch.programModule.programStage;

  final programs = await programQuery.get();

  final program = Program(
    id: 'test1',
    name: "Test 1",
    shortName: 'Test 1',
    dirty: false,
    captureCoordinates: true,
    completeEventsExpiryDays: 15,
    displayIncidentDate: '',
    enrollmentDateLabel: '',
    featureType: '',
    ignoreOverdueEvents: true,
    incidentDateLabel: '',
    onlyEnrollOnce: false,
    organisationUnits: '',
    programRuleVariables: '',
    programType: 'EVENT',
    selectEnrollmentDatesInFuture: true,
    selectIncidentDatesInFuture: false,
    trackedEntity: '',
    trackedEntityType: '',
    useFirstStageDuringRegistration: true,
    withoutRegistration: true,
  );

  var insertResult = await programQuery.setData(program).save();

  test('should return success if data is inserted into the database', () {
    expect(insertResult, 1);
  });

  var result = await programQuery.byId('test1').getOne();

  test('should return saved details', () {
    expect(result.id, 'test1');
    expect(result.name, 'Test 1');
    expect(result.shortName, 'Test 1');
    expect(result.programType, 'EVENT');
    expect(result.captureCoordinates, true);
  });

  final programStage = ProgramStage(
      id: 'programstage1',
      name: 'Program Stage 1',
      shortName: 'Program Stage 1',
      featureType: '',
      captureCoordinates: false,
      sortOrder: 1,
      allowGenerateNextVisit: true,
      autoGenerateEvent: true,
      blockEntryForm: true,
      dueDateLabel: 'Due Date',
      executionDateLabel: 'Execution Date',
      formType: 'DEFAULT',
      generatedByEnrollmentDate: false,
      hideDueDate: false,
      minDaysFromStart: 3,
      program: Program(
          id: 'program1',
          name: 'Program 1',
          shortName: 'Program1',
          dirty: false,
          programType: 'TRACKER'),
      programStageDataElements: [],
      programStageSections: [],
      repeatable: false,
      dirty: false);

  var insertProgramStageResult =
      await programStageQuery.setData(programStage).save();

  test('should return success if program stage is inserted into the database',
      () {
    expect(insertProgramStageResult, 1);
  });
}
