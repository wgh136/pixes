import 'package:fluent_ui/fluent_ui.dart';

import '../components/message.dart' as overlay;
import '../components/page_route.dart';

extension Navigation on BuildContext {
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  Future<T?> to<T>(Widget Function() builder) {
    return Navigator.of(this)
        .push<T>(AppPageRoute(builder: (context) => builder()));
  }

  void showToast({required String message, IconData? icon}) {
    overlay.showToast(this, message: message, icon: icon);
  }

  Size get size => MediaQuery.of(this).size;

  EdgeInsets get padding => MediaQuery.of(this).padding;
}
