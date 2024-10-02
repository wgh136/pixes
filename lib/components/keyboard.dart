import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixes/foundation/app.dart';

typedef KeyEventHandler = void Function(LogicalKeyboardKey key);

class KeyEventListener extends StatefulWidget {
  const KeyEventListener({required this.child, super.key});

  final Widget child;

  static KeyEventListenerState? of(BuildContext context) {
    return context.findAncestorStateOfType<KeyEventListenerState>();
  }

  @override
  State<KeyEventListener> createState() => KeyEventListenerState();
}

class KeyEventListenerState extends State<KeyEventListener> {
  final focusNode = FocusNode();

  final List<KeyEventHandler> _handlers = [];

  void addHandler(KeyEventHandler handler) {
    _handlers.add(handler);
  }

  void removeHandler(KeyEventHandler handler) {
    _handlers.remove(handler);
  }

  void removeAll() {
    _handlers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyUpEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (App.rootNavigatorKey.currentState?.canPop() ?? false) {
            App.rootNavigatorKey.currentState?.pop();
          } else if (App.mainNavigatorKey?.currentState?.canPop() ?? false) {
            App.mainNavigatorKey?.currentState?.pop();
          }
          return KeyEventResult.handled;
        }
        for (var handler in _handlers) {
          handler(event.logicalKey);
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
