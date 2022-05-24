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

import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';

class BeagleJsEngineJsHelpers {
  final globalBeagle = 'global.beagle';
  final JavascriptRuntimeWrapper _jsRuntime;

  BeagleJsEngineJsHelpers(JavascriptRuntimeWrapper jsRuntime) : _jsRuntime = jsRuntime;

  Future<dynamic> deserializeJsFunctions(dynamic value, [String? viewId]) async {
    if (value is String) {
      if (value.toString().startsWith('__beagleFn:')) {
        return ([dynamic argument]) async {
          final args = argument == null ? "'$value'" : "'$value', ${json.encode(argument)}";
          final jsMethod = viewId == null ? 'call(' : "callViewFunction('$viewId', ";
          _jsRuntime.evaluateAsync('$globalBeagle.$jsMethod$args)');
        };
      }
    }

    if (value is List) {
      final listValue = value as List<dynamic>;
      final result = List.empty(growable: true);

      for (final listItem in listValue) {
        result.add(await deserializeJsFunctions(listItem, viewId));
      }

      return result;
    }

    if (value is Map) {
      final map = value as Map<String, dynamic>;
      final result = <String, dynamic>{};
      final keys = map.keys;

      // ignore: cascade_invocations, avoid_function_literals_in_foreach_calls
      for (final key in keys) {
        result[key] = await deserializeJsFunctions(map[key], viewId);
      }

      return result;
    }

    return value;
  }

  void callJsFunction(String functionId, [Map<String, dynamic>? argsMap]) {
    _jsRuntime.evaluateAsync('$globalBeagle.call("$functionId"${argsMap != null ? ", ${json.encode(argsMap)}" : ""})');
  }
}
