import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/log.dart';
import 'package:pixes/utils/ext.dart';

export 'package:dio/dio.dart';

class MyLogInterceptor implements Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.error("Network",
        "${err.requestOptions.method} ${err.requestOptions.path}\n$err\n${err.response?.data.toString()}");
    switch (err.type) {
      case DioExceptionType.badResponse:
        var statusCode = err.response?.statusCode;
        if (statusCode != null) {
          err = err.copyWith(
              message: "Invalid Status Code: $statusCode. "
                  "${_getStatusCodeInfo(statusCode)}");
        }
      case DioExceptionType.connectionTimeout:
        err = err.copyWith(message: "Connection Timeout");
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(
            message: "Receive Timeout: "
                "This indicates that the server is too busy to respond");
      case DioExceptionType.unknown:
        if (err.toString().contains("Connection terminated during handshake")) {
          err = err.copyWith(
              message: "Connection terminated during handshake: "
                  "This may be caused by the firewall blocking the connection "
                  "or your requests are too frequent.");
        } else if (err.toString().contains("Connection reset by peer")) {
          err = err.copyWith(
              message: "Connection reset by peer: "
                  "The error is unrelated to app, please check your network.");
        }
      default:
        {}
    }
    handler.next(err);
  }

  static const errorMessages = <int, String>{
    400: "The Request is invalid.",
    401: "The Request is unauthorized.",
    403: "No permission to access the resource. Check your account or network.",
    404: "Not found.",
    429: "Too many requests. Please try again later.",
  };

  String _getStatusCodeInfo(int? statusCode) {
    if (statusCode != null && statusCode >= 500) {
      return "This is server-side error, please try again later. "
          "Do not report this issue.";
    } else {
      return errorMessages[statusCode] ?? "";
    }
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    var headers = response.headers.map.map((key, value) => MapEntry(
        key.toLowerCase(), value.length == 1 ? value.first : value.toString()));
    headers.remove("cookie");
    String content;
    if (response.data is List<int>) {
      content = "<Bytes>\nlength:${response.data.length}";
    } else {
      content = response.data.toString();
    }
    Log.addLog(
        (response.statusCode != null && response.statusCode! < 400)
            ? LogLevel.info
            : LogLevel.error,
        "Network",
        "Response ${response.realUri.toString()} ${response.statusCode}\n"
            "headers:\n$headers\n$content");
    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout = const Duration(seconds: 15);
    options.receiveTimeout = const Duration(seconds: 15);
    options.sendTimeout = const Duration(seconds: 15);
    if (options.headers["Host"] == null && options.headers["host"] == null) {
      options.headers["host"] = options.uri.host;
    }
    Log.info("Network",
        "${options.method} ${options.uri}\n${options.headers}\n${options.data}");
    handler.next(options);
  }
}

class AppDio extends DioForNative {
  bool isInitialized = false;

  @override
  Future<Response<T>> request<T>(String path,
      {Object? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) {
    if (!isInitialized) {
      isInitialized = true;
      interceptors.add(MyLogInterceptor());
    }
    return super.request(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }
}

void setSystemProxy() {
  HttpOverrides.global = _ProxyHttpOverrides()..findProxy(Uri());
}

class _ProxyHttpOverrides extends HttpOverrides {
  String proxy = "DIRECT";

  String findProxy(Uri uri) {
    var haveUserProxy = appdata.settings["proxy"] != null &&
        appdata.settings["proxy"].toString().removeAllBlank.isNotEmpty;
    if (!App.isLinux && !haveUserProxy) {
      var channel = const MethodChannel("pixes/proxy");
      channel.invokeMethod("getProxy").then((value) {
        if (value.toString().toLowerCase() == "no proxy") {
          proxy = "DIRECT";
        } else {
          if (proxy.contains("https")) {
            var proxies = value.split(";");
            for (String proxy in proxies) {
              proxy = proxy.removeAllBlank;
              if (proxy.startsWith('https=')) {
                value = proxy.substring(6);
              }
            }
          }
          proxy = "PROXY $value";
        }
      });
    } else {
      if (haveUserProxy) {
        proxy = "PROXY ${appdata.settings["proxy"]}";
      }
    }
    // check validation
    if (proxy.startsWith("PROXY")) {
      var uri = proxy.replaceFirst("PROXY", "").removeAllBlank;
      if (!uri.startsWith("http")) {
        uri += "http://";
      }
      if (!uri.isURL) {
        return "DIRECT";
      }
    }
    return proxy;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.connectionTimeout = const Duration(seconds: 5);
    client.findProxy = findProxy;
    return client;
  }
}
