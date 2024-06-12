import 'package:pixes/foundation/app.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:pixes/network/models.dart';

class IllustHistory {
  final int id;
  final String imgPath;
  final DateTime time;
  final int imageCount;
  final bool isR18;
  final bool isR18G;
  final bool isAi;
  final bool isGif;
  final int width;
  final int height;

  IllustHistory(this.id, this.imgPath, this.time, this.imageCount, this.isR18,
      this.isR18G, this.isAi, this.isGif, this.width, this.height);
}

class HistoryManager {
  static HistoryManager? instance;

  factory HistoryManager() => instance ??= HistoryManager._create();

  HistoryManager._create();

  late Database _db;

  init() {
    _db = sqlite3.open("${App.dataPath}/history.db");
    _db.execute('''
      create table if not exists history (
        id integer primary key not null,
        imgPath text not null,
        time integer not null,
        imageCount integer not null,
        isR18 integer not null,
        isR18g integer not null,
        isAi integer not null,
        isGif integer not null,
        width integer not null,
        height integer not null
      )
    ''');
  }

  void addHistory(Illust illust) {
    var time = DateTime.now();
    _db.execute('''
      insert or replace into history (id, imgPath, time, imageCount, isR18, isR18g, isAi, isGif, width, height)
      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      illust.id,
      illust.images.first.medium,
      time.millisecondsSinceEpoch,
      illust.pageCount,
      illust.isR18 ? 1 : 0,
      illust.isR18G ? 1 : 0,
      illust.isAi ? 1 : 0,
      illust.isUgoira ? 1 : 0,
      illust.width,
      illust.height
    ]);
    if(length > 1000) {
      _db.execute('''
        delete from history where id in (
          select id from history order by time asc limit 100
        )
      ''');
    }
  }

  List<IllustHistory> getHistories(int page) {
    var rows = _db.select('''
      select * from history order by time desc
      limit 20 offset ? 
    ''', [(page - 1) * 20]);
    List<IllustHistory> res = [];
    for (var row in rows) {
      res.add(IllustHistory(
          row['id'],
          row['imgPath'],
          DateTime.fromMillisecondsSinceEpoch(row['time']),
          row['imageCount'],
          row['isR18'] == 1,
          row['isR18g'] == 1,
          row['isAi'] == 1,
          row['isGif'] == 1,
          row['width'],
          row['height']));
    }
    return res;
  }

  int get length {
    var rows = _db.select('''
      select count(*) from history
    ''');
    return rows.first.values.first! as int;
  }
}
