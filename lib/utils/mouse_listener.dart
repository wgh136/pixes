import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../foundation/app.dart';

void mouseSideButtonCallback(GlobalKey<NavigatorState> key) {
  if (App.rootNavigatorKey.currentState?.canPop() ?? false) {
    App.rootNavigatorKey.currentState?.pop();
    return;
  }
  if (key.currentState?.canPop() ?? false) {
    key.currentState?.pop();
  }
}

///监听鼠标侧键, 若为下键, 则调用返回
void listenMouseSideButtonToBack(GlobalKey<NavigatorState> key) async {
  if (!App.isWindows) {
    return;
  }
  const channel = EventChannel("pixes/mouse");
  await for (var res in channel.receiveBroadcastStream()) {
    if (res == 0) {
      mouseSideButtonCallback(key);
    }
  }
}
