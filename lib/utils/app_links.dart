import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/log.dart';
import 'package:win32_registry/win32_registry.dart';

Future<void> _register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

bool Function(Uri uri)? onLink;

void handleLinks() async {
  if (App.isWindows) {
    await _register("pixiv");
  }
  AppLinks().uriLinkStream.listen((uri) {
    Log.info("App Link", uri.toString());
    if (onLink?.call(uri) == true) {
      return;
    }
  });
}
