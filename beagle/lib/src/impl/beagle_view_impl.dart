/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/impl/local_contexts_manager_impl.dart';
import 'package:beagle/src/impl/renderer_impl.dart';

/// Creates a new Beagle View. If this view is created by a navigator, it must be specified in the constructor.
class BeagleViewImpl implements BeagleView {
  BeagleViewImpl(this._parentNavigator, this._beagleService) {
    _id = "${nextViewId++}";
    BeagleViewImpl.views[_id] = this;

    _renderer = RendererImpl(this);
    _localContextsManager = LocalContextsManagerImpl(this);
  }

  static Map<String, BeagleViewImpl> views = {};

  static int nextViewId = 0;

  final List<ViewChangeListener> viewChangeListeners = [];

  final List<ActionListener> actionListeners = [];

  late final String _id;

  late Renderer _renderer;

  late LocalContextsManager _localContextsManager;

  final BeagleService _beagleService;

  final BeagleNavigator _parentNavigator;

  BeagleUIElement? tree;

  @override
  void destroy() {
    viewChangeListeners.clear();
    actionListeners.clear();
    views.remove(_id);
  }

  @override
  BeagleNavigator getNavigator() => _parentNavigator;

  @override
  LocalContextsManager getLocalContexts() => _localContextsManager;

  @override
  BeagleService getBeagleService() => _beagleService;

  @override
  GlobalContext getGlobalContext() {
    return _beagleService.globalContext;
  }

  @override
  Renderer getRenderer() => _renderer;

  @override
  BeagleUIElement? getTree() {
    return tree?.clone();
  }

  @override
  void setTree(BeagleUIElement tree) {
    this.tree = tree.clone();
  }

  @override
  void notifyChange(BeagleUIElement? updatedTree) {
    for (var listener in viewChangeListeners) {
      if (updatedTree != null) {
        listener.call(updatedTree);
      }
    }
  }

  @override
  void notifyAction(BeagleAction action, BeagleUIElement element) {
    for (var listener in actionListeners) {
      listener.call(action: action, view: this, element: element);
    }
  }

  @override
  void Function() onChange(ViewChangeListener listener) {
    viewChangeListeners.add(listener);
    return () => viewChangeListeners.remove(listener);
  }

  @override
  void Function() onAction(ActionListener listener) {
    actionListeners.add(listener);
    return () => actionListeners.remove(listener);
  }

  @override
  void doFullRender() {
    if (tree != null) _renderer.doFullRender(tree!);
  }
}
