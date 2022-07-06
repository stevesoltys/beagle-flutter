import 'package:beagle/beagle.dart';
import 'package:beagle/src/impl/beagle_component.dart';
import 'package:beagle/src/impl/beagle_context.dart';
import 'package:collection/collection.dart';

import 'beagle_action.dart';
import 'beagle_expression.dart';

class RendererImpl implements Renderer {
  final globalBeagle = "global.beagle";

  final BeagleView beagleView;

  RendererImpl(this.beagleView);

  @override
  void doFullRender(BeagleUIElement treeToRender, [String? anchor, TreeUpdateMode mode = TreeUpdateMode.replace]) {
    if (anchor != null && mode == TreeUpdateMode.replace) {
      treeToRender.setId(anchor);
    }

    Tree.forEach(treeToRender, (component, index) {
      Component.assignId(component);
    });

    doPartialRender(treeToRender, anchor, mode);
  }

  @override
  void doPartialRender(BeagleUIElement treeToRender, [String? anchor, TreeUpdateMode mode = TreeUpdateMode.replace]) {
    final treeSnapshot = takeViewSnapshot(treeToRender, anchor, mode);
    // final evaluatedTree = evaluateComponents(treeSnapshot);

    beagleView.notifyChange(treeSnapshot);
  }

  @override
  void doTemplateRender({
    required TemplateManager templateManager,
    required String anchor,
    required List<List<BeagleDataContext>> contexts,
    BeagleUIElement Function(BeagleUIElement, int)? componentManager,
    TreeUpdateMode? mode,
  }) {
    final logger = beagleView.getBeagleService().logger;
    final tree = beagleView.getTree();

    if (tree == null) {
      return;
    }

    final anchorElement = Tree.findById(tree, anchor);

    if (anchorElement == null) {
      logger.error("Beagle can't do the template rendering because it couldn't find the node "
          "identified by the provided anchor: $anchor.");
      return;
    }

    final List<Map<String, dynamic>> templatesWithContext = [];
    final contextMap = BeagleContext.getNodeContextMap(tree);

    contexts.forEachIndexed((index, contextList) {
      final Map<String, dynamic> templateContext = {};

      for (final element in contextList) {
        templateContext[element.id] = element.value;
      }

      final evaluatedTemplate = getEvaluatedTemplate(templateManager, templateContext, contextMap, anchor);

      if (evaluatedTemplate != null) {
        var matchedTemplateTree = evaluatedTemplate.clone();
        var componentManagerEvaluatedTree = componentManager?.call(matchedTemplateTree, index).properties ?? {};

        final finalTree = {...matchedTemplateTree.properties, ...componentManagerEvaluatedTree, "context": templateContext};
        templatesWithContext.add(finalTree);
      }
    });

    anchorElement.setChildren(templatesWithContext);
    doFullRender(anchorElement, anchor);
  }

  BeagleUIElement? getEvaluatedTemplate(
      TemplateManager templates, Map<String, dynamic> templateContext, Map<String, Map<String, dynamic>> contextMap, String anchor) {
    final successTemplate = templates.templates?.firstWhereOrNull((template) {
      return template.condition != null &&
          BeagleExpressions.evaluateExpression(beagleView, template.condition!, contextMap, implicitContext: templateContext, nodeId: anchor) == true;
    });

    return successTemplate?.view ?? templates.defaultTemplate;
  }

  BeagleUIElement evaluateComponents(BeagleUIElement treeToRender) {
    // final localContexts = []; //beagleView.getLocalContexts().getAllAsDataContext();
    // final contextMap = Context.evaluateContext(treeToRender, [...localContexts, ...beagleView.getGlobalContext().getAllAsDataContext()]);
    final actionStartTime = DateTime.now().millisecondsSinceEpoch;
    BeagleActions.initializeActions(treeToRender, beagleView);
    print("Initialize actions took ${DateTime.now().millisecondsSinceEpoch - actionStartTime}ms");

    final exressionStartTime = DateTime.now().millisecondsSinceEpoch;
    BeagleExpressions.initializeExpressions(treeToRender, beagleView);
    print("Initialize expressions took ${DateTime.now().millisecondsSinceEpoch - exressionStartTime}ms");

    return treeToRender;
  }

  BeagleUIElement takeViewSnapshot(BeagleUIElement treeToRender, String? anchor, TreeUpdateMode mode) {
    var currentTree = beagleView.getTree();

    if (currentTree == null) {
      beagleView.setTree(treeToRender);
      return treeToRender;
    }

    anchor ??= currentTree.getId();

    if (mode == TreeUpdateMode.replace) {
      if (anchor == currentTree.getId()) {
        currentTree = treeToRender;
      } else {
        Tree.replaceInTree(currentTree, treeToRender, anchor);
      }
    } else {
      Tree.insertInTree(currentTree, treeToRender, anchor, mode);
    }

    beagleView.setTree(currentTree);
    return currentTree;
  }
}
