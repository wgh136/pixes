import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:pixes/foundation/app.dart';
import 'package:window_manager/window_manager.dart';

class WindowPlacement {
  final Rect rect;

  final bool isMaximized;

  const WindowPlacement(this.rect, this.isMaximized);

  Future<void> applyToWindow() async {
    await windowManager.setBounds(rect);

    if (isMaximized) {
      await windowManager.maximize();
    }
  }

  Future<void> writeToFile() async {
    var file = File("${App.dataPath}/window_placement");
    await file.writeAsString(jsonEncode({
      'width': rect.width,
      'height': rect.height,
      'x': rect.topLeft.dx,
      'y': rect.topLeft.dy,
      'isMaximized': isMaximized
    }));
  }

  static Future<WindowPlacement> loadFromFile() async {
    var file = File("${App.dataPath}/window_placement");
    if (!file.existsSync()) {
      return defaultPlacement;
    }
    var json = jsonDecode(await file.readAsString());
    var rect =
        Rect.fromLTWH(json['x'], json['y'], json['width'], json['height']);
    return WindowPlacement(rect, json['isMaximized']);
  }

  static Future<WindowPlacement> get current async {
    var rect = await windowManager.getBounds();
    var isMaximized = await windowManager.isMaximized();
    return WindowPlacement(rect, isMaximized);
  }

  static const defaultPlacement =
      WindowPlacement(Rect.fromLTWH(10, 10, 900, 600), false);

  static WindowPlacement cache = defaultPlacement;

  static void loop() async {
    var placement = await WindowPlacement.current;
    if (placement.rect != cache.rect ||
        placement.isMaximized != cache.isMaximized) {
      cache = placement;
      await placement.writeToFile();
    }
  }
}
