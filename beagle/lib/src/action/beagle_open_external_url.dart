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
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

class BeagleOpenExternalUrl {
  static Future<void> launchURL(BuildContext buildContext, String url, bool external) async {
    final uri = Uri.parse(url);

    if (await launcher.canLaunchUrl(uri)) {
      final launchMode = external ? LaunchMode.externalApplication : LaunchMode.platformDefault;

      await launcher.launchUrl(uri, mode: launchMode);
    } else {
      final logger = findBeagleService(buildContext).logger;
      logger.error('Could not launch $url');
    }
  }
}
