import 'package:beagle/beagle.dart';
import 'package:beagle/src/impl/beagle_expression.dart';

import 'beagle_context.dart';

class BeagleActions {
  static final IGNORE_ACTION_KEYS = ["id", "child", "children", "context", "templates", "_beagleComponent_"];

  static void initializeActions(BeagleUIElement tree, BeagleView view) {
    traverse(tree, view, tree.properties, {});
  }

  static void traverse(BeagleUIElement tree, BeagleView view, dynamic properties, Map<String, dynamic> parentActionContext) {
    if (properties is Map<String, dynamic>) {
      properties.forEach((actionListKey, child) {
        if (isActionList(child)) {
          properties[actionListKey] = actionFunctionFor(tree, view, properties, parentActionContext, actionListKey, child);
        } else {
          if (!IGNORE_ACTION_KEYS.contains(actionListKey)) {
            traverse(tree, view, child, parentActionContext);
          }
        }
      });
    } else if (properties is List<dynamic>) {
      for (final child in properties) {
        traverse(tree, view, child, parentActionContext);
      }
    }
  }

  static bool isActionList(dynamic childProperty) {
    return childProperty is List<dynamic> && childProperty.any((element) => element is Map<String, dynamic> && element.containsKey("_beagleAction_"));
  }

  static dynamic actionFunctionFor(BeagleUIElement componentTree, BeagleView view, Map<String, dynamic> actionTree, Map<String, dynamic> parentActionContext,
      String actionListKey, List<dynamic> actionList) {
    componentTree = componentTree.clone();

    return ([data]) {
      actionList.forEach((actionPropertiesMap) {
        Map<String, dynamic> context = componentTree.properties['context'] ?? {};
        context.addAll(parentActionContext);

        if (data != null) {
          context[actionListKey] = data;
        }

        final finalMap = BeagleUIElement({...actionPropertiesMap, "context": context}).clone();
        traverse(componentTree, view, finalMap.properties, context);
        BeagleExpressions.initializeExpressions(finalMap, view);

        final action = BeagleAction(finalMap.properties);
        view.notifyAction(action, componentTree);
      });
    };
  }
}
