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
import 'package:beagle/src/model/json_encodable.dart';
import 'package:flutter/widgets.dart';

class BeagleUIElement {
  BeagleUIElement(this.properties) {
    if (properties['child'] != null) {
      properties['children'] = [properties['child']];
      properties.remove('child');
    }
  }

  Map<String, dynamic> properties;

  String getId() {
    return properties['id'] ?? '';
  }

  void setId(String id) {
    properties['id'] = id;
  }

  Key getKey() {
    return ValueKey(getId());
  }

  String getType() {
    return properties['_beagleComponent_'].toString();
  }

  Map<String, dynamic>? getContext() {
    if (!properties.containsKey('context')) {
      return null;
    }
    return properties['context'];
  }

  bool hasChildren() {
    return properties.containsKey('children') &&
        // ignore: avoid_as
        (properties['children'] as List<dynamic>).isNotEmpty;
  }

  List<BeagleUIElement> getChildren() {
    if (!properties.containsKey('children')) {
      return [];
    }

    final list = (properties['children'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((child) => BeagleUIElement(child)).toList();
  }

  void setChildren(List<Map<String, dynamic>> children) {
    properties['children'] = children;
  }

  void replaceChild(int index, BeagleUIElement child) {
    if (hasChildren()) {
      properties['children'][index] = child.properties;
    } else {
      throw Exception("Tried to replace child on Beagle UI element that has no children.");
    }
  }

  void insertChild(int index, BeagleUIElement child) {
    if (hasChildren()) {
      properties['children'].insert(index, child);
    } else {
      throw Exception("Tried to insert child on Beagle UI element that has no children.");
    }
  }

  void appendChild(BeagleUIElement child) {
    if (hasChildren()) {
      properties['children'].add(child);
    } else {
      throw Exception("Tried to insert child on Beagle UI element that has no children.");
    }
  }

  dynamic getAttributeValue(String attributeName, [dynamic defaultValue]) {
    return properties.containsKey(attributeName) ? properties[attributeName] : defaultValue;
  }

  BeagleStyle? getStyle() {
    return properties.containsKey('style') ? BeagleStyle.fromMap(properties['style']) : null;
  }

  BeagleAccessibility? getAccessibility() {
    return properties.containsKey('accessibility') ? BeagleAccessibility.fromMap(properties['accessibility']) : null;
  }

  BeagleUIElement clone() {
    return BeagleUIElement(cloneFrom(properties));
  }

  dynamic cloneFrom(dynamic data) {
    if (data is List<dynamic>) {
      final List<dynamic> resultList = [];

      for (final element in data) {
        resultList.add(cloneFrom(element));
      }

      return resultList;
    } else if (data is Map<String, dynamic>) {
      final Map<String, dynamic> resultMap = {};

      data.forEach((String key, dynamic childData) {
        resultMap[key] = cloneFrom(childData);
      });

      return resultMap;
    } else {
      return data;
    }
  }

  static bool isBeagleUIElement(Map<String, dynamic>? json) {
    return json != null && json.containsKey("_beagleComponent_");
  }

  void forEach(void Function(Map<String, dynamic> node, int index) iteratee) {
    if (properties.isEmpty) return;
    int index = 0;

    void run(Map<String, dynamic> node) {
      iteratee(node, index++);
      final children = node['children'];
      if (children is List) {
        for (var c in children) {
          run(c);
        }
      }
    }

    run(properties);
  }

  @override
  String toString() => jsonEncode(properties, toEncodable: (value) => (value is JsonEncodable) ? value.toJson() : '');
}
