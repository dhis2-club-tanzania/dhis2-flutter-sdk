import 'package:d2_touch/modules/engine/program_rule/models/math_expressions.dart';
import 'package:d2_touch/modules/engine/program_rule/run-d2-expression.util.dart';
import 'package:d2_touch/modules/engine/shared/utilities/data_value_entities.util.dart';
import 'package:d2_touch/modules/metadata/program/entities/program_rule.entity.dart';
import 'package:d2_touch/modules/metadata/program/entities/program_rule_action.entity.dart';
import 'package:d2_touch/modules/metadata/program/entities/program_rule_variable.entity.dart';
import 'package:expressions/expressions.dart';

class ProgramRuleEngine {
  static _getEvaluationContext(
      {required Map<String, DataValueObject> dataValueEntities,
      required List<ProgramRuleVariable> programRuleVariables}) {
    Map<String, dynamic> evaluationContext = {};

    programRuleVariables.forEach((programRuleVariable) {
      final value = dataValueEntities[
              programRuleVariable.trackedEntityAttribute ??
                  programRuleVariable.dataElement]
          ?.value;

      evaluationContext = {
        ...evaluationContext,
        "${programRuleVariable.name}": value
      };
    });

    return evaluationContext;
  }

  static _parseRuleValue(value) {
    if (value == null) {
      return '';
    }

    bool isDouble = false;

    try {
      double.parse(value);
      isDouble = true;
    } catch (e) {}

    if (isDouble) {
      return value;
    }

    bool isInt = false;
    try {
      int.parse(value);
      isInt = true;
    } catch (e) {}

    if (isInt) {
      return value;
    }

    return "'$value'";
  }

  static List<ProgramRuleAction> execute(
      {required Map<String, DataValueObject> dataValueEntities,
      required List<ProgramRule> programRules,
      required List<ProgramRuleVariable> programRuleVariables}) {
    List<ProgramRuleAction> programRulesActions = [];

    Map<String, dynamic> evaluationContext =
        ProgramRuleEngine._getEvaluationContext(
            dataValueEntities: dataValueEntities,
            programRuleVariables: programRuleVariables);

    programRules.forEach((programRule) {
      String ruleConditionForEvaluation = programRule.condition;

      evaluationContext.keys.forEach((key) {
        final value = evaluationContext[key];
        ruleConditionForEvaluation = ruleConditionForEvaluation.replaceAll(
            "#{" + key + "}", ProgramRuleEngine._parseRuleValue(value));

        ruleConditionForEvaluation = ruleConditionForEvaluation.replaceAll(
            "A{" + key + "}", ProgramRuleEngine._parseRuleValue(value));
      });

      // d2 functions
      if (ruleConditionForEvaluation.contains('d2:')) {
        ruleConditionForEvaluation =
            dhisD2Functions(ruleConditionForEvaluation, {});
      }

      try {
        Expression expression = Expression.parse(ruleConditionForEvaluation);

        final evaluator = const ExpressionEvaluator();
        dynamic evaluationResult =
            evaluator.eval(expression, evaluationContext);

        final newProgramRuleActions =
            programRule.programRuleActions?.map((ruleAction) {
          String data = ruleAction.data ?? '';
          return ProgramRuleAction.fromJson({
            ...ruleAction.toJson(),
            'data':
                data != '' && evaluationResult == true && data.contains('#{')
                    ? MathExpressions.evaluate(data, evaluationContext)
                    : ruleAction.data,
            'programRuleActionType':
                evaluationResult == true ? ruleAction.programRuleActionType : ""
          });
        }).toList();

        programRulesActions = List.from([
          ...programRulesActions,
          ...(newProgramRuleActions as List<ProgramRuleAction>)
        ]);
      } catch (e) {
        final newProgramRuleActions =
            programRule.programRuleActions?.map((ruleAction) {
          return ProgramRuleAction.fromJson(
              {...ruleAction.toJson(), 'programRuleActionType': ''});
        }).toList();

        programRulesActions = List.from([
          ...programRulesActions,
          ...(newProgramRuleActions as List<ProgramRuleAction>)
        ]);
      }
    });

    return programRulesActions;
  }
}
