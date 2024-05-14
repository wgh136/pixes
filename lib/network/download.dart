import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/log.dart';
import 'package:pixes/network/app_dio.dart';
import 'package:pixes/network/network.dart';
import 'package:pixes/utils/io.dart';
import 'package:sqlite3/sqlite3.dart';

extension IllustExt on Illust {
  bool get downloaded => DownloadManager().checkDownloaded(id);

  bool get downloading =>
      DownloadManager().tasks.any((element) => element.illust.id == id);
}

class DownloadedIllust {
  final int illustId;
  final String title;
  final String author;
  final int imageCount;

  DownloadedIllust({
    required this.illustId,
    required this.title,
    required this.author,
    required this.imageCount,
  });
}

class DownloadingTask {
  final Illust illust;

  void Function(int)? receiveBytesCallback;

  void Function(DownloadingTask)? onCompleted;

  DownloadingTask(this.illust, {this.receiveBytesCallback, this.onCompleted});

  int _downloadingIndex = 0;

  int get totalImages => illust.images.length;

  int get downloadedImages => _downloadingIndex;

  bool _stop = true;

  String? error;

  void start() {
    _stop = false;
    _download();
  }

  Dio get dio => Network().dio;

  void cancel() {
    _stop = true;
    DownloadManager().tasks.remove(this);
    for(var path in imagePaths) {
      File(path).deleteIfExists();
    }
  }

  List<String> imagePaths = [];

  void _download() async{
    try{
      while(_downloadingIndex < illust.images.length) {
        if(_stop) return;
        var url = illust.images[_downloadingIndex].original;
        var ext = url.split('.').last;
        if(!["jpg", "png", "gif", "webp", "jpeg", "avif"].contains(ext)) {
          ext = "jpg";
        }
        var path = _generateFilePath(illust, _downloadingIndex, ext);
        final time = DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
        final hash = md5.convert(utf8.encode(time + Network.hashSalt)).toString();
        var res = await dio.get<ResponseBody>(url, options: Options(
          responseType: ResponseType.stream,
          headers: {
            "referer": "https://app-api.pixiv.net/",
            "user-agent": "PixivAndroidApp/5.0.234 (Android 14; Pixes)",
            "x-client-time": time,
            "x-client-hash": hash,
            "accept-enconding": "gzip",
          },
        ));
        var file = File(path);
        if(!file.existsSync()) {
          file.createSync(recursive: true);
        }
        await for (var data in res.data!.stream) {
          await file.writeAsBytes(data, mode: FileMode.append);
          receiveBytesCallback?.call(data.length);
        }
        imagePaths.add(path);
        _downloadingIndex++;
      }
      onCompleted?.call(this);
    }
    catch(e, s) {
      error = e.toString();
      _stop = true;
      Log.error("Download", "Download error: $e\n$s");
    }
  }

  static String _generateFilePath(Illust illust, int index, String ext) {
    final String downloadPath = appdata.settings["downloadPath"];
    String subPathPatten = appdata.settings["downloadSubPath"];
    final tags = appdata.settings["useTranslatedNameForDownload"] == false
        ? illust.tags.map((e) => e.name).toList()
        : illust.tags.map((e) => e.translatedName ?? e.name).toList();
    final tagsWeight = (appdata.settings["tagsWeight"] as String).split(' ');
    tags.sort((a, b) => tagsWeight.indexOf(a) - tagsWeight.indexOf(b));
    subPathPatten = subPathPatten.replaceAll(r"${id}", illust.id.toString());
    subPathPatten = subPathPatten.replaceAll(r"${title}", illust.title);
    subPathPatten = subPathPatten.replaceAll(r"${author}", illust.author.name);
    subPathPatten = subPathPatten.replaceAll(r"${index}", index.toString());
    subPathPatten = subPathPatten.replaceAll(r"${ext}", ext);
    for(int i=0; i<tags.length; i++) {
      subPathPatten = subPathPatten.replaceAll("\${tag$i}", tags[i]);
    }
    return "$downloadPath$subPathPatten";
  }

  void retry() {
    error = null;
    _stop = false;
    _download();
  }
}

class DownloadManager {
  factory DownloadManager() => instance ??= DownloadManager._();

  static DownloadManager? instance;

  DownloadManager._(){
    init();
  }

  late Database _db;

  int _currentBytes = 0;
  int _bytesPerSecond = 0;

  int get bytesPerSecond => _bytesPerSecond;

  Timer? _loop;

  var tasks = <DownloadingTask>[];

  void Function()? uiUpdateCallback;

  void registerUiUpdater(void Function() callback) {
    uiUpdateCallback = callback;
  }

  void removeUiUpdater() {
    uiUpdateCallback = null;
  }

  void init() {
    _db = sqlite3.open("${App.dataPath}/download.db");
    _db.execute('''
      create table if not exists download (
        illust_id integer primary key not null,
        title text not null,
        author text not null,
        imageCount int not null
      );
    ''');
    _db.execute('''
      create table if not exists images (
        illust_id integer not null,
        image_index integer not null,
        path text not null,
        primary key (illust_id, image_index)
      );
    ''');
  }

  void saveInfo(Illust illust, List<String> imagePaths) {
    _db.execute('''
      insert into download (illust_id, title, author, imageCount)
      values (?, ?, ?, ?)
    ''', [illust.id, illust.title, illust.author.name, imagePaths.length]);
    for (var i = 0; i < imagePaths.length; i++) {
      _db.execute('''
        insert into images (illust_id, image_index, path)
        values (?, ?, ?)
      ''', [illust.id, i, imagePaths[i]]);
    }
  }

  File? getImage(int illustId, int index) {
    var res = _db.select('''
      select * from images
      where illust_id = ? and image_index = ?;
    ''', [illustId, index]);
    if (res.isEmpty) return null;
    var file = File(res.first["path"] as String);
    if (!file.existsSync()) return null;
    return file;
  }

  bool checkDownloaded(int illustId) {
    var res = _db.select('''
      select * from download
      where illust_id = ?;
    ''', [illustId]);
    return res.isNotEmpty;
  }

  List<DownloadedIllust> listAll() {
    var res = _db.select('''
      select * from download;
    ''');
    return res.map((e) =>
        DownloadedIllust(
          illustId: e["illust_id"] as int,
          title: e["title"] as String,
          author: e["author"] as String,
          imageCount: e["imageCount"] as int,
        )).toList();
  }

  void addDownloadingTask(Illust illust) {
    var task = DownloadingTask(illust, receiveBytesCallback: receiveBytes, onCompleted: (task) {
      saveInfo(illust, task.imagePaths);
      tasks.remove(task);
    });
    tasks.add(task);
    run();
  }

  void receiveBytes(int bytes) {
    _currentBytes += bytes;
  }

  int get maxConcurrentTasks => 3;

  void run() {
    _loop ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      _bytesPerSecond = _currentBytes;
      _currentBytes = 0;
      uiUpdateCallback?.call();
      for(int i=0; i<maxConcurrentTasks; i++) {
        var task = tasks.elementAtOrNull(i);
        if(task != null && task._stop && task.error == null) {
          task.start();
        }
      }
      if(tasks.isEmpty) {
        timer.cancel();
        _loop = null;
        _currentBytes = 0;
        _bytesPerSecond = 0;
      }
    });
  }

  void delete(DownloadedIllust illust) {
    _db.execute('''
      delete from download
      where illust_id = ?;
    ''', [illust.illustId]);
    var images = _db.select('''
      select * from images
      where illust_id = ?;
    ''', [illust.illustId]);
    for(var image in images) {
      File(image["path"] as String).deleteIfExists();
    }
    _db.execute('''
      delete from images
      where illust_id = ?;
    ''', [illust.illustId]);
  }

  List<String> getImagePaths(int illustId) {
    var res = _db.select('''
      select * from images
      where illust_id = ?;
    ''', [illustId]);
    return res.map((e) => e["path"] as String).toList();
  }
}