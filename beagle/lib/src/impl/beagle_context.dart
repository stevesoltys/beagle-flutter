// function evaluate(
//   viewTree: IdentifiableBeagleUIElement,
//   globalContexts: DataContext[] = [],
//   includeImplicitContexts = true,
// ): Record<string, DataContext[]> {
//   const contextMap: Record<string, DataContext[]> = {}
//
//   function evaluateContextHierarchy(
//     component: IdentifiableBeagleUIElement,
//     contextHierarchy: DataContext[],
//   ) {
//     checkContextId(component)
//
//     const hierarchy = [...contextHierarchy, ...getContexts(component, includeImplicitContexts)]
//
//     contextMap[component.id] = hierarchy
//     if (!component.children) return
//     component.children.forEach(child => evaluateContextHierarchy(child, hierarchy))
//   }
//
//   evaluateContextHierarchy(viewTree, globalContexts)
//
//   return contextMap
// }

import 'package:beagle/beagle.dart';

class BeagleContext {
  static Map<String, Map<String, dynamic>> getNodeContextMap(BeagleUIElement tree, {bool includeImplicitContexts = true}) {
    Map<String, Map<String, dynamic>> resultMap = {};

    evaluateContextHierarchy(tree, {}, includeImplicitContexts, resultMap);
    return resultMap;
  }

  static void evaluateContextHierarchy(
      BeagleUIElement component, Map<String, dynamic> contextHierarchy, bool includeImplicitContexts, Map<String, Map<String, dynamic>> resultMap) {
    // checkContextId(component) TODO: Check for reserved words

    final hierarchy = {...contextHierarchy, ...getContexts(component, includeImplicitContexts)};
    resultMap[component.getId()] = hierarchy;

    component.getChildren().forEach((child) {
      evaluateContextHierarchy(child, hierarchy, includeImplicitContexts, resultMap);
    });
  }

  static Map<String, dynamic> getContexts(BeagleUIElement component, bool includeImplicitContexts) {
    Map<String, dynamic> contexts = {};

    component.getContext()?.forEach((key, value) {
      contexts[key] = value;
    });

    // TODO: Implicit contexts.
    // if (includeImplicitContexts && component._implicitContexts_) {
    //   component._implicitContexts_.forEach(c => contexts.push(c))}
    return contexts;
  }
}
