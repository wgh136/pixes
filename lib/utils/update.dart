import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/app_dio.dart';
import 'package:pixes/utils/translation.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<String> getLatestVersion() async {
  var dio = AppDio();
  var res = await dio.get(
      "https://raw.githubusercontent.com/wgh136/pixes/refs/heads/master/pubspec.yaml");
  var lines = (res.data as String).split("\n");
  for (var line in lines) {
    if (line.startsWith("version:")) {
      return line.split(":")[1].split('+')[0].trim();
    }
  }
  throw "Failed to get latest version";
}

/// Compare two versions.
/// Return `true` if `a` is greater than `b`.
bool compareVersion(String a, String b) {
  var aList = a.split(".").map(int.parse).toList();
  var bList = b.split(".").map(int.parse).toList();
  for (var i = 0; i < aList.length; i++) {
    if (aList[i] > bList[i]) {
      return true;
    } else if (aList[i] < bList[i]) {
      return false;
    }
  }
  return false;
}

Future<void> checkUpdate() async {
  if (appdata.account == null) return;
  try {
    var latestVersion = await getLatestVersion();
    if (compareVersion(latestVersion, App.version)) {
      showDialog(
          context: App.rootNavigatorKey.currentContext!,
          builder: (context) => ContentDialog(
                title: Text("New version available".tl),
                content: Text(
                  "A new version of Pixes is available. Do you want to update now?"
                      .tl,
                ),
                actions: [
                  Button(
                    child: Text("Cancel".tl),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FilledButton(
                      child: Text("Update".tl),
                      onPressed: () {
                        Navigator.of(context).pop();
                        launchUrlString(
                            "https://github.com/wgh136/pixes/releases/latest");
                      })
                ],
              ));
    }
  } catch (e) {
    // ignore
  }
}
