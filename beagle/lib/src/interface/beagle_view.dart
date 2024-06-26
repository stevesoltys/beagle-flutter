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

import 'package:beagle/beagle.dart';

typedef ViewChangeListener = void Function(BeagleUIElement tree);

typedef ActionListener = void Function({
  required BeagleAction action,
  required BeagleView view,
  required BeagleUIElement element,
});

abstract class BeagleView {
  /// Subscribes [listener] to every change to the beagle tree. This method returns a function that,
  /// when called, undoes the subscription (removes the listener).
  RemoveListener onChange(ViewChangeListener listener);

  /// Gets the local context manager of the current BeagleView, which manage each local context.
  LocalContextsManager getLocalContexts();

  /// Gets the renderer of the current BeagleView. Can be used to control the rendering directly.
  Renderer getRenderer();

  /// Gets a copy of the currently rendered tree.
  BeagleUIElement? getTree();

  void setTree(BeagleUIElement tree);

  void notifyChange(BeagleUIElement? tree);

  void notifyAction(BeagleAction action, BeagleUIElement element);

  void doFullRender();

  GlobalContext getGlobalContext();

  BeagleService getBeagleService();

  /// Gets the navigator that spawned this Beagle View, if any.
  BeagleNavigator getNavigator();

  /// Destroys the current view. Should be used when the BeagleView won't be used anymore. Avoids
  /// memory leaks and calls to objects that don't exist any longer.
  void destroy();

  /// Subscribes [listener] to every action triggered by the view or its children.
  /// This method returns a function that, when called, undoes the subscription (removes the listener).
  RemoveListener onAction(ActionListener listener);
}
