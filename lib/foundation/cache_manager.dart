import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pixes/utils/io.dart';
import 'package:sqlite3/sqlite3.dart';

import 'app.dart';

class CacheManager {
  static String get cachePath => '${App.cachePath}/cache';

  static CacheManager? instance;

  late Database _db;

  int? _currentSize;

  /// size in bytes
  int get currentSize => _currentSize ?? 0;

  int dir = 0;

  int _limitSize = 2 * 1024 * 1024 * 1024;

  CacheManager._create() {
    Directory(cachePath).createSync(recursive: true);
    _db = sqlite3.open('${App.dataPath}/cache.db');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS cache (
        key TEXT PRIMARY KEY NOT NULL,
        dir TEXT NOT NULL,
        name TEXT NOT NULL,
        expires INTEGER NOT NULL
      )
    ''');
    compute((path) => Directory(path).size, cachePath)
        .then((value) => _currentSize = value);
  }

  factory CacheManager() => instance ??= CacheManager._create();

  /// set cache size limit in bytes
  void setLimitSize(int size) {
    _limitSize = size;
  }

  Future<void> writeCache(String key, Uint8List data,
      [int duration = 7 * 24 * 60 * 60 * 1000]) async {
    this.dir++;
    this.dir %= 100;
    var dir = this.dir;
    var name = md5.convert(Uint8List.fromList(key.codeUnits)).toString();
    var file = File('$cachePath/$dir/$name');
    while (await file.exists()) {
      name = md5.convert(Uint8List.fromList(name.codeUnits)).toString();
      file = File('$cachePath/$dir/$name');
    }
    await file.create(recursive: true);
    await file.writeAsBytes(data);
    var expires = DateTime.now().millisecondsSinceEpoch + duration;
    _db.execute('''
      INSERT OR REPLACE INTO cache (key, dir, name, expires) VALUES (?, ?, ?, ?)
    ''', [key, dir.toString(), name, expires]);
    if (_currentSize != null) {
      _currentSize = _currentSize! + data.length;
    }
    if (_currentSize != null && _currentSize! > _limitSize) {
      await checkCache();
    }
  }

  Future<CachingFile> openWrite(String key) async {
    this.dir++;
    this.dir %= 100;
    var dir = this.dir;
    var name = md5.convert(Uint8List.fromList(key.codeUnits)).toString();
    var file = File('$cachePath/$dir/$name');
    while (await file.exists()) {
      name = md5.convert(Uint8List.fromList(name.codeUnits)).toString();
      file = File('$cachePath/$dir/$name');
    }
    await file.create(recursive: true);
    return CachingFile._(key, dir.toString(), name, file);
  }

  Future<String?> findCache(String key) async {
    var res = _db.select('''
      SELECT * FROM cache
      WHERE key = ?
    ''', [key]);
    if (res.isEmpty) {
      return null;
    }
    var row = res.first;
    var dir = row.values[1] as String;
    var name = row.values[2] as String;
    var file = File('$cachePath/$dir/$name');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  bool _isChecking = false;

  Future<void> checkCache() async {
    if (_isChecking) {
      return;
    }
    _isChecking = true;
    var res = _db.select('''
      SELECT * FROM cache
      WHERE expires < ?
    ''', [DateTime.now().millisecondsSinceEpoch]);
    for (var row in res) {
      var dir = row.values[1] as int;
      var name = row.values[2] as String;
      var file = File('$cachePath/$dir/$name');
      if (await file.exists()) {
        await file.delete();
      }
    }
    _db.execute('''
      DELETE FROM cache
      WHERE expires < ?
    ''', [DateTime.now().millisecondsSinceEpoch]);

    while (_currentSize != null && _currentSize! > _limitSize) {
      var res = _db.select('''
        SELECT * FROM cache
        ORDER BY time ASC
        limit 10
      ''');
      for (var row in res) {
        var key = row.values[0] as String;
        var dir = row.values[1] as int;
        var name = row.values[2] as String;
        var file = File('$cachePath/$dir/$name');
        if (await file.exists()) {
          var size = await file.length();
          await file.delete();
          _db.execute('''
            DELETE FROM cache
            WHERE key = ?
          ''', [key]);
          _currentSize = _currentSize! - size;
          if (_currentSize! <= _limitSize) {
            break;
          }
        } else {
          _db.execute('''
            DELETE FROM cache
            WHERE key = ?
          ''', [key]);
        }
      }
    }
    _isChecking = false;
  }

  Future<void> delete(String key) async {
    var res = _db.select('''
      SELECT * FROM cache
      WHERE key = ?
    ''', [key]);
    if (res.isEmpty) {
      return;
    }
    var row = res.first;
    var dir = row.values[1] as String;
    var name = row.values[2] as String;
    var file = File('$cachePath/$dir/$name');
    var fileSize = 0;
    if (await file.exists()) {
      fileSize = await file.length();
      await file.delete();
    }
    _db.execute('''
      DELETE FROM cache
      WHERE key = ?
    ''', [key]);
    if (_currentSize != null) {
      _currentSize = _currentSize! - fileSize;
    }
  }

  Future<void> clear() async {
    await Directory(cachePath).delete(recursive: true);
    Directory(cachePath).createSync(recursive: true);
    _db.execute('''
      DELETE FROM cache
    ''');
    _currentSize = 0;
  }

  Future<void> deleteKeyword(String keyword) async {
    var res = _db.select('''
      SELECT * FROM cache
      WHERE key LIKE ?
    ''', ['%$keyword%']);
    for (var row in res) {
      var key = row.values[0] as String;
      var dir = row.values[1] as String;
      var name = row.values[2] as String;
      var file = File('$cachePath/$dir/$name');
      var fileSize = 0;
      if (await file.exists()) {
        fileSize = await file.length();
        await file.delete();
      }
      _db.execute('''
        DELETE FROM cache
        WHERE key = ?
      ''', [key]);
      if (_currentSize != null) {
        _currentSize = _currentSize! - fileSize;
      }
    }
  }
}

class CachingFile {
  CachingFile._(this.key, this.dir, this.name, this.file);

  final String key;

  final String dir;

  final String name;

  final File file;

  final List<int> _buffer = [];

  Future<void> writeBytes(List<int> data) async {
    _buffer.addAll(data);
    if (_buffer.length > 1024 * 1024) {
      await file.writeAsBytes(_buffer, mode: FileMode.append);
      _buffer.clear();
    }
  }

  Future<void> close() async {
    if (_buffer.isNotEmpty) {
      await file.writeAsBytes(_buffer, mode: FileMode.append);
    }
    CacheManager()._db.execute('''
      INSERT OR REPLACE INTO cache (key, dir, name, expires) VALUES (?, ?, ?, ?)
    ''', [
      key,
      dir,
      name,
      DateTime.now().millisecondsSinceEpoch + 7 * 24 * 60 * 60 * 1000
    ]);
  }

  Future<void> cancel() async {
    await file.deleteIfExists();
  }
}
