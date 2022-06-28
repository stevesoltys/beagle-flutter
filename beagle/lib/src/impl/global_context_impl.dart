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

import 'dart:collection';
import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/impl/beagle_view_impl.dart';

/// Access to the Global Context API. Use it to set persistent values that can be retrieved and
/// manipulated by the widgets rendered by Beagle.
class GlobalContextImpl implements GlobalContext {
  final Map<String, dynamic> context = {};

  @override
  void clear([String? path]) {
    context.clear();

    BeagleViewImpl.views.forEach((key, view) {
      view.doFullRender();
    });
  }

  @override
  T get<T>([String? path]) {
    if (path != null) {
      return context[path];
    }

    return context as T;
  }

  @override
  void set<T>(T value, [String? path]) {
    if (path != null) {
      final split = path.split(".");
      Map<dynamic, dynamic> currentPathMap = context;

      for (var index = 0; index < split.length; index++) {
        final currentPathKey = split[index];

        if (index == split.length - 1) {
          currentPathMap[currentPathKey] = value;
        } else {
          if (currentPathMap[currentPathKey] == null) {
            currentPathMap[currentPathKey] = <dynamic, dynamic>{};
          }

          currentPathMap = currentPathMap[currentPathKey];
        }
      }
    } else {
      context.clear();
      context.addAll(value as Map<String, dynamic>);
    }

    BeagleViewImpl.views.forEach((key, view) {
      view.doFullRender();
    });
  }

  @override
  List<BeagleDataContext> getAllAsDataContext() {
    return [];
  }

  @override
  Map<String, dynamic> getContext() {
    // clone the context
    return json.decode(json.encode(context));
  }
}
