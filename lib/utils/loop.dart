import 'dart:async';

class Loop {
  static final List<void Function()> _callbacks = [];

  static void start() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      for (var func in _callbacks) {
        func.call();
      }
    });
  }

  static void register(void Function() func) {
    _callbacks.add(func);
  }

  static void remove(void Function() func) {
    _callbacks.remove(func);
  }
}
