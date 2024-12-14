import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/components/md.dart';
import 'package:pixes/foundation/app.dart';

void showToast(BuildContext context, {required String message, IconData? icon}) {
  var newEntry = OverlayEntry(
      builder: (context) => ToastOverlay(message: message, icon: icon));

  var overlay = OverlayWidget.of(context);

  overlay?.addOverlay(newEntry);

  Timer(const Duration(seconds: 2), () => overlay?.remove(newEntry));
}

class ToastOverlay extends StatelessWidget {
  const ToastOverlay({required this.message, this.icon, super.key});

  final String message;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: PhysicalModel(
          color: ColorScheme.of(context).surface.toOpacity(1),
          borderRadius: BorderRadius.circular(4),
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) Icon(icon),
                if (icon != null)
                  const SizedBox(
                    width: 8,
                  ),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorScheme.of(context).onSurface
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayWidget extends StatefulWidget {
  const OverlayWidget(this.child, {super.key});

  final Widget child;

  static OverlayWidgetState? of(BuildContext context) {
    return LookupBoundary.findAncestorStateOfType<OverlayWidgetState>(context);
  }

  @override
  State<OverlayWidget> createState() => OverlayWidgetState();
}

class OverlayWidgetState extends State<OverlayWidget> {
  var overlayKey = GlobalKey<OverlayState>();

  var entries = <OverlayEntry>[];

  void addOverlay(OverlayEntry entry) {
    if (overlayKey.currentState != null) {
      overlayKey.currentState!.insert(entry);
      entries.add(entry);
    }
  }

  void remove(OverlayEntry entry) {
    if (entries.remove(entry)) {
      entry.remove();
    }
  }

  void removeAll() {
    for (var entry in entries) {
      entry.remove();
    }
    entries.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: overlayKey,
      initialEntries: [OverlayEntry(builder: (context) => widget.child)],
    );
  }
}
