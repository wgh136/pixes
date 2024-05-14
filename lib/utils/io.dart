import 'dart:io';

extension FSExt on FileSystemEntity {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }

  int get size {
    if (this is File) {
      return (this as File).lengthSync();
    } else if(this is Directory){
      var size = 0;
      for(var file in (this as Directory).listSync()){
        size += file.size;
      }
      return size;
    }
    return 0;
  }
}

extension DirectoryExt on Directory {
  bool havePermission() {
    if(!existsSync()) return false;
    try {
      listSync();
      return true;
    } catch (e) {
      return false;
    }
  }
}

String bytesToText(int bytes) {
  if(bytes < 1024) {
    return "$bytes B";
  } else if(bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(2)} KB";
  } else if(bytes < 1024 * 1024 * 1024) {
    return "${(bytes / 1024 / 1024).toStringAsFixed(2)} MB";
  } else {
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
  }
}