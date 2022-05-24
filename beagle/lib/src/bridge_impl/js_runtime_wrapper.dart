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

import 'package:flutter_js/flutter_js.dart';

import 'js_runtime_isolated.dart';

class JavascriptRuntimeWrapper {
  JavascriptRuntimeWrapper();

  final JsRuntimeIsolated _jsRuntime = JsRuntimeIsolated(stackSize: 1024 * 1024);

  Future<JsEvalResult>? evaluateAsync(String code) async {
    final result = await _jsRuntime.evaluate(code);

    return JsEvalResult(result.toString(), result, isError: false, isPromise: false);
  }

  void onMessage(String channelName, Future<void> Function(dynamic args) fn) {
    _jsRuntime.setupBridge(channelName, fn);
  }
}
