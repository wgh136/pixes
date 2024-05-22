import 'package:pixes/appdata.dart';
import 'package:pixes/network/models.dart';

void checkIllusts(List<Illust> illusts) {
  illusts.removeWhere((illust) {
    if (illust.isBlocked) {
      return true;
    }
    if (appdata.settings["blockTags"] == null) {
      return false;
    }
    if (appdata.settings["blockTags"].contains(illust.author.name)) {
      return true;
    }
    for (var tag in illust.tags) {
      if ((appdata.settings["blockTags"] as List).contains(tag.name)) {
        return true;
      }
    }
    return false;
  });
}
