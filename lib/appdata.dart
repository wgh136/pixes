import 'dart:convert';
import 'dart:io';

import 'foundation/app.dart';
import 'network/models.dart';

class _Appdata {
  Account? account;

  var searchOptions = SearchOptions();

  void writeData() async {
    await File("${App.dataPath}/account.json")
        .writeAsString(jsonEncode(account));
  }

  Future<void> readData() async {
    final file = File("${App.dataPath}/account.json");
    if (file.existsSync()) {
      account = Account.fromJson(jsonDecode(await file.readAsString()));
    }
  }
}

final appdata = _Appdata();
