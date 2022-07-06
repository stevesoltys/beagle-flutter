import 'package:beagle/beagle.dart';

class Component {
  static const CHILDREN_PROPERTY_NAMES = ['child'];
  static const ID_PREFIX = '_beagle_';
  static var nextId = 1;

  static void assignId(BeagleUIElement component) {
    final currentId = component.getId();

    if (currentId == '') {
      component.setId("$ID_PREFIX${nextId++}");
    }
  }
}

class Tree {
  static void forEach(BeagleUIElement tree, Function(BeagleUIElement tree, int index) iteratee, {int index = 0}) {
    iteratee(tree, index++);

    for (final child in tree.getChildren()) {
      forEach(child, iteratee, index: index);
    }
  }

  static BeagleUIElement? findById(BeagleUIElement tree, String childId) {
    if (tree.getId() == childId) {
      return tree;
    }

    for (final child in tree.getChildren()) {
      final result = findById(child, childId);

      if(result != null) {
        return result;
      }
    }

    return null;
  }

  static BeagleUIElement? findParentByChildId(BeagleUIElement tree, String childId) {
    var i = 0;
    BeagleUIElement? parent;

    while (i < tree.getChildren().length && parent == null) {
      final child = tree.getChildren()[i];
      if (child.getId() == childId) {
        parent = tree;
      } else {
        parent = findParentByChildId(child, childId);
      }
      i++;
    }

    return parent;
  }

  static void replaceInTree(BeagleUIElement tree, BeagleUIElement component, String anchor) {
    final parent = findParentByChildId(tree, anchor);

    if (parent == null) {
      return;
    }

    final index = parent.getChildren().indexWhere((element) => element.getId() == anchor);
    parent.replaceChild(index, component);
  }

  static void insertInTree(BeagleUIElement tree, BeagleUIElement component, String anchor, TreeUpdateMode mode) {
    final child = findById(tree, anchor);

    if (child == null) {
      return;
    }

    if (mode == TreeUpdateMode.append) {
      child.appendChild(tree);
    } else if (mode == TreeUpdateMode.prepend) {
      child.insertChild(0, tree);
    }

    // TODO: ?
    // else if(mode == TreeUpdateMode.replace) {
    //
    // }
  }
}
