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
import 'package:beagle/src/bridge_impl/handlers/base.dart';
import 'package:beagle/src/bridge_impl/utils.dart';
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';

class BeagleJSEngineViewUpdateHandler implements BeagleJSEngineBaseHandlerWithListenersMap {
  final BeagleJsEngineJsHelpers _jsHelpers;

  BeagleJSEngineViewUpdateHandler(JavascriptRuntimeWrapper jsRuntime) : _jsHelpers = BeagleJsEngineJsHelpers(jsRuntime);

  @override
  final Map<String, List<ViewChangeListener>> listenersMap = {};

  final Map<String, BeagleUIElement> lastUpdates = {};

  @override
  String get channelName => 'beagleView.update';

  @override
  void removeViewListener(String viewId) => listenersMap.remove(viewId);

  @override
  void notify(dynamic message) {
    final viewId = message['id'];
    final deserialized = _jsHelpers.deserializeJsFunctions(message['tree'], viewId);
    final uiElement = BeagleUIElement(deserialized);

    if (lastUpdates[viewId] == null || lastUpdates[viewId]?.properties != uiElement.properties) {
      for (ViewChangeListener listener in (listenersMap[viewId] ?? [])) {
        listener(uiElement);
      }

      lastUpdates[viewId] = uiElement;
    }
  }
}
