import 'dart:async';
import 'dart:ui';

class Debounce {
  final Duration delay;
  VoidCallback? _action;
  Timer? _timer;

  Debounce({required this.delay});

  void call(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    _timer = Timer(delay, _execute);
  }

  void _execute() {
    if (_action != null) {
      _action!();
      _action = null;
    }
  }

  void cancel() {
    _timer?.cancel();
    _action = null;
  }
}