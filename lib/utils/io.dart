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