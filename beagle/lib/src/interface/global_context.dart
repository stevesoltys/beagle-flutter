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
import 'package:beagle/src/interface/contexts/base.dart';

/// A Global Context is a class that can assume a value of any variable type. This is similar to a map that defines a subset
/// of key/value or complex JSONs objects that defines object trees.
///
/// It works exactly like the Context, however in a global scope, meaning that it will exists while the application is
/// still running (even in the background), which allows it to be accessed from any application point, this point being a component
/// or an action linked to a component conventionally or programmatically.
abstract class GlobalContext implements BaseContext {
  /// Gets a value in the global context according to the [path] passed as parameter. The [path] is
  /// optional, if not passed, the entire global context is returned. If no value is found for the
  /// provided [path], null is returned.
  ///
  /// Example of [path]: if the global context has an object named `user`, with an array named
  /// `documents` and you want the first document, use `user.documents[0]` as [path].
  ///
  /// The type returned by this function is always one of the following: Map, Array, num, bool or
  /// String.
  @override
  T get<T>([String path]);

  /// Sets a [value] in the global context according to the [path] passed as parameter. The [path]
  /// can be ommited, in this case, the [value] is set to the entire global context.
  ///
  /// The [path] follow the same rules as the method `get`. Example: `order.items`.
  ///
  /// All values in the GlobalContext must be encodable, i.e. Map, Array, number, bool or String.
  /// If the [value] is not encodable, an exception is thrown.
  @override
  void set<T>(T value, [String path]);

  /// Removes a value from the global context according to the [path] passed as parameter.
  ///
  /// - If the provided [path] doesn't exist, nothing happens.
  /// - If the provided [path] refers to a key of a map, the key is removed from the map.
  /// - If the provided [path] refers to an element of a list, the element is set to null.
  /// - If [path] is ommited, the entire global context is set to null.
  @override
  void clear([String path]);

  List<BeagleDataContext> getAllAsDataContext();

  Map<String, dynamic> getContext();
}
