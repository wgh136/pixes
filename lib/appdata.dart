import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'foundation/app.dart';
import 'network/models.dart';

class _Appdata {
  Account? account;

  var searchOptions = SearchOptions();

  Map<String, dynamic> settings = {
    "downloadPath": null,
    "downloadSubPath": r"/${id}-p${index}.${ext}",
    "tagsWeight": "",
    "useTranslatedNameForDownload": false,
  };

  void writeData() async {
    await File("${App.dataPath}/account.json")
        .writeAsString(jsonEncode(account));
    await File("${App.dataPath}/settings.json")
        .writeAsString(jsonEncode(settings));
  }

  Future<void> readData() async {
    final file = File("${App.dataPath}/account.json");
    if (file.existsSync()) {
      account = Account.fromJson(jsonDecode(await file.readAsString()));
    }
    final settingsFile = File("${App.dataPath}/settings.json");
    if (settingsFile.existsSync()) {
      var json = jsonDecode(await settingsFile.readAsString());
      for(var key in json.keys) {
        settings[key] = json[key];
      }
    }
    if(settings["downloadPath"] == null) {
      settings["downloadPath"] = await _defaultDownloadPath;
    }
  }

  String get downloadPath => settings["downloadPath"];

  Future<String> get _defaultDownloadPath async{
    if(App.isAndroid) {
      var externalStoragePaths = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      var res = externalStoragePaths?.first.path;
      res ??= (await getExternalStorageDirectory())!.path;
      return "$res/pixes";
    } else if (App.isWindows){
      var res = await const MethodChannel("pixes/picture_folder").invokeMethod("");
      if(res != "error") {
        return res + "/pixes";
      }
    } else if (App.isMacOS || App.isLinux) {
      var downloadPath = (await getDownloadsDirectory())?.path;
      if(downloadPath != null) {
        return "$downloadPath/pixes";
      }
    }

    return "${App.dataPath}/download";
  }
}

final appdata = _Appdata();
