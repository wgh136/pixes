import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../appdata.dart';

export "widget_utils.dart";
export "state_controller.dart";
export "navigation.dart";

class _App {
  final version = "1.0.1";

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;
  bool get isWindows => Platform.isWindows;
  bool get isLinux => Platform.isLinux;
  bool get isMacOS => Platform.isMacOS;
  bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  bool get isMobile => Platform.isAndroid || Platform.isIOS;

  Locale get locale {
    if(appdata.settings["language"] != "System"){
      return switch(appdata.settings["language"]){
        "English" => const Locale("en"),
        "简体中文" => const Locale("zh"),
        "繁體中文" => const Locale("zh", "Hant"),
        _ => const Locale("en"),
      };
    }
    Locale deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == "zh" && deviceLocale.scriptCode == "Hant") {
      deviceLocale = const Locale("zh", "TW");
    }
    return deviceLocale;
  }

  late String dataPath;
  late String cachePath;

  init() async{
    cachePath = (await getApplicationCacheDirectory()).path;
    dataPath = (await getApplicationSupportDirectory()).path;
  }

  final rootNavigatorKey = GlobalKey<NavigatorState>();
}

// ignore: non_constant_identifier_names
final App = _App();
