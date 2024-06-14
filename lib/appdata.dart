import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixes/utils/io.dart';

import 'foundation/app.dart';
import 'network/models.dart';

class _Appdata {
  Account? account;

  var searchOptions = SearchOptions();

  Map<String, dynamic> settings = {
    "downloadPath": null,
    "downloadSubPath": r"/${id}-p${index}.${ext}",
    "maxParallels": 3,
    "proxy": "",
    "darkMode": "System",
    "language": "System",
    "readingFontSize": 16.0,
    "readingLineHeight": 1.5,
    "readingParagraphSpacing": 8.0,
    "blockTags": [],
    "shortcuts": <int>[
      LogicalKeyboardKey.arrowDown.keyId,
      LogicalKeyboardKey.arrowUp.keyId,
      LogicalKeyboardKey.arrowRight.keyId,
      LogicalKeyboardKey.arrowLeft.keyId,
      LogicalKeyboardKey.enter.keyId,
      LogicalKeyboardKey.keyD.keyId,
      LogicalKeyboardKey.keyF.keyId,
      LogicalKeyboardKey.keyC.keyId,
      LogicalKeyboardKey.keyG.keyId,
    ],
    "showOriginalImage": false,
    "checkUpdate": true,
    "emphasizeArtworksFromFollowingArtists": true,
  };

  bool lock = false;

  void writeData() async {
    while (lock) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    lock = true;
    await File("${App.dataPath}/account.json")
        .writeAsString(jsonEncode(account));
    await File("${App.dataPath}/settings.json")
        .writeAsString(jsonEncode(settings));
    lock = false;
  }

  void writeSettings() async {
    while (lock) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    lock = true;
    await File("${App.dataPath}/settings.json")
        .writeAsString(jsonEncode(settings));
    lock = false;
  }

  Future<void> readData() async {
    final file = File("${App.dataPath}/account.json");
    if (file.existsSync()) {
      var json = jsonDecode(await file.readAsString());
      if (json != null) {
        account = Account.fromJson(json);
      }
    }
    final settingsFile = File("${App.dataPath}/settings.json");
    if (settingsFile.existsSync()) {
      var json = jsonDecode(await settingsFile.readAsString());
      for (var key in json.keys) {
        if (json[key] != null) {
          if (json[key] is List && settings[key] is List) {
            for (int i = 0;
                i < json[key].length && i < settings[key].length;
                i++) {
              settings[key][i] = json[key][i];
            }
          } else {
            settings[key] = json[key];
          }
        }
      }
    }
    if (settings["downloadPath"] == null) {
      settings["downloadPath"] = await _defaultDownloadPath;
    }
  }

  Future<String> get _defaultDownloadPath async {
    if (App.isAndroid) {
      String? downloadPath = "/storage/emulated/0/download";
      if (!Directory(downloadPath).havePermission()) {
        downloadPath = null;
      }
      var res = downloadPath;
      res ??= (await getExternalStorageDirectory())!.path;
      return "$res/pixes";
    } else if (App.isWindows) {
      var res =
          await const MethodChannel("pixes/picture_folder").invokeMethod("");
      if (res != "error") {
        return res + "/pixes";
      }
    } else if (App.isMacOS || App.isLinux) {
      var downloadPath = (await getDownloadsDirectory())?.path;
      if (downloadPath != null && Directory(downloadPath).havePermission()) {
        return "$downloadPath/pixes";
      }
    }

    return "${App.dataPath}/download";
  }
}

final appdata = _Appdata();
