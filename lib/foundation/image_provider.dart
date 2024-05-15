import 'dart:async' show Future, StreamController, scheduleMicrotask;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui show Codec;
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pixes/network/app_dio.dart';
import 'package:pixes/network/network.dart';

import 'cache_manager.dart';

class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message);

  @override
  String toString() {
    return message;
  }
}

abstract class BaseImageProvider<T extends BaseImageProvider<T>>
    extends ImageProvider<T> {
  const BaseImageProvider();

  @override
  ImageStreamCompleter loadImage(T key, ImageDecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadBufferAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: 1.0,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'Image provider: $this \n Image key: $key',
          this,
          style: DiagnosticsTreeStyle.errorProperty,
        );
      },
    );
  }

  Future<ui.Codec> _loadBufferAsync(
      T key,
      StreamController<ImageChunkEvent> chunkEvents,
      ImageDecoderCallback decode,
      ) async {
    try {
      int retryTime = 1;

      bool stop = false;

      chunkEvents.onCancel = () {
        stop = true;
      };

      Uint8List? data;

      while (data == null && !stop) {
        try {
          data = await load(chunkEvents);
        } catch (e) {
          if (e.toString().contains("Your IP address")) {
            rethrow;
          }
          if (e is BadRequestException) {
            rethrow;
          }
          if (e.toString().contains("handshake")) {
            if (retryTime < 5) {
              retryTime = 5;
            }
          }
          retryTime <<= 1;
          if (retryTime > (2 << 3) || stop) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: retryTime));
        }
      }

      if(stop) {
        throw Exception("Image loading is stopped");
      }

      if(data!.isEmpty) {
        throw Exception("Empty image data");
      }

      try {
        final buffer = await ImmutableBuffer.fromUint8List(data);
        return await decode(buffer);
      } catch (e) {
        await CacheManager().delete(this.key);
        Object error = e;
        if (data.length < 200) {
          // data is too short, it's likely that the data is text, not image
          try {
            var text = utf8.decoder.convert(data);
            error = Exception("Expected image data, but got text: $text");
          } catch (e) {
            // ignore
          }
        }
        throw error;
      }
    } catch (e) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<Uint8List> load(StreamController<ImageChunkEvent> chunkEvents);

  String get key;

  @override
  bool operator ==(Object other) {
    return other is BaseImageProvider<T> && key == other.key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return "$runtimeType($key)";
  }
}

typedef FileDecoderCallback = Future<ui.Codec> Function(Uint8List);

class CachedImageProvider extends BaseImageProvider<CachedImageProvider> {
  final String url;

  CachedImageProvider(this.url);

  @override
  String get key => url;

  @override
  Future<Uint8List> load(StreamController<ImageChunkEvent> chunkEvents) async{
    chunkEvents.add(const ImageChunkEvent(
      cumulativeBytesLoaded: 0,
      expectedTotalBytes: 1,
    ));
    var cached = await CacheManager().findCache(key);
    if(cached != null) {
      chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 1,
        expectedTotalBytes: 1,
      ));
      return await File(cached).readAsBytes();
    }
    var dio = AppDio();
    final time = DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
    final hash = md5.convert(utf8.encode(time + Network.hashSalt)).toString();
    var res = await dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          "referer": "https://app-api.pixiv.net/",
          "user-agent": "PixivAndroidApp/5.0.234 (Android 14; Pixes)",
          "x-client-time": time,
          "x-client-hash": hash,
          "accept-enconding": "gzip",
        }
      )
    );
    if(res.statusCode != 200) {
      throw BadRequestException("Failed to load image: ${res.statusCode}");
    }
    var data = <int>[];
    var cachingFile = await CacheManager().openWrite(key);
    await for (var chunk in res.data!.stream) {
      var length = res.data!.contentLength+1;
      if(length < data.length) {
        length = data.length + 1;
      }
      data.addAll(chunk);
      await cachingFile.writeBytes(chunk);
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: data.length,
        expectedTotalBytes: length,
      ));
    }
    await cachingFile.close();
    return Uint8List.fromList(data);
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }
}
