import 'package:beagle/beagle.dart';
import 'package:beagle/src/impl/beagle_context.dart';
import 'package:template_expressions/expressions.dart';

class BeagleExpressions {
  static final expressionPattern = RegExp("^\\@\\{(.+)\\}\$");

  static final IGNORE_COMPONENT_KEYS = ["id", "child", "children", "context", "templates", "_beagleComponent_"];

  static void initializeExpressions(BeagleUIElement tree, BeagleView view) {
    final contextMap = BeagleContext.getNodeContextMap(tree);

    traverse(view, tree.properties, contextMap);
  }

  static dynamic traverse(BeagleView view, dynamic data, Map<String, Map<String, dynamic>> contextMap, {String? nodeId}) {
    if (data is List<dynamic>) {
      data.forEach((element) {
        traverse(view, element, contextMap);
      });
    } else if (data is Map<String, dynamic>) {
      data.forEach((String key, dynamic childData) {
        if (!IGNORE_COMPONENT_KEYS.contains(key)) {
          data[key] = traverse(view, childData, contextMap, nodeId: data["id"] ?? '');
        }
      });
    } else if (data is String) {
      if (expressionPattern.hasMatch(data)) {
        return evaluateExpression(view, data, contextMap, nodeId: nodeId);
      }
    }

    return data;
  }

  static dynamic evaluateExpression(BeagleView view, String expressionTemplate, Map<String, dynamic> nodeContextMap,
      {Map<String, dynamic>? implicitContext, String? nodeId}) {
    final match = expressionPattern.firstMatch(expressionTemplate)!;
    final expression = match.group(1)!;

    final globalContext = view.getGlobalContext().getContext();
    final viewContext = view.getLocalContexts().getAllContext();
    final nodeContext = nodeContextMap[nodeId];
    Map<String, dynamic> contextMap = {"global": globalContext};

    viewContext.forEach((key, value) {
      contextMap[key] = value;
    });

    nodeContext?.forEach((key, value) {
      contextMap[key] = value;
    });

    implicitContext?.forEach((key, value) {
      contextMap[key] = value;
    });

    try {
      final parsedExpression = Expression.parse(expression);
      final evaluator = const ExpressionEvaluator();

      final result = evaluator.eval(parsedExpression, contextMap);
      return result;
    } catch (ex) {
      view.getBeagleService().logger.error("Could not evaluate $expression: " + ex.toString());
    }

    return null;
  }
}
