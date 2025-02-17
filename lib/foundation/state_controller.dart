import 'package:flutter/material.dart';
import 'pair.dart';

class SimpleController extends StateController {
  final void Function()? refresh_;

  SimpleController({this.refresh_});

  @override
  void refresh() {
    (refresh_ ?? super.refresh)();
  }
}

abstract class StateController {
  static final _controllers = <StateControllerWrapped>[];

  static T put<T extends StateController>(T controller,
      {Object? tag, bool autoRemove = false}) {
    _controllers.add(StateControllerWrapped(controller, autoRemove, tag));
    return controller;
  }

  static T putIfNotExists<T extends StateController>(T controller,
      {Object? tag, bool autoRemove = false}) {
    return findOrNull<T>(tag: tag) ??
        put(controller, tag: tag, autoRemove: autoRemove);
  }

  static T find<T extends StateController>({Object? tag}) {
    try {
      return _controllers
          .lastWhere((element) =>
              element.controller is T && (tag == null || tag == element.tag))
          .controller as T;
    } catch (e) {
      throw StateError("${T.runtimeType} with tag $tag Not Found");
    }
  }

  static T? findOrNull<T extends StateController>({Object? tag}) {
    try {
      return _controllers
          .lastWhere((element) =>
              element.controller is T && (tag == null || tag == element.tag))
          .controller as T;
    } catch (e) {
      return null;
    }
  }

  static void remove<T>([Object? tag, bool check = false]) {
    for (int i = _controllers.length - 1; i >= 0; i--) {
      var element = _controllers[i];
      if (element.controller is T && (tag == null || tag == element.tag)) {
        if (check && !element.autoRemove) {
          continue;
        }
        _controllers.removeAt(i);
        return;
      }
    }
  }

  static SimpleController putSimpleController(
      void Function() onUpdate, Object? tag,
      {void Function()? refresh}) {
    var controller = SimpleController(refresh_: refresh);
    controller.stateUpdaters.add(Pair(null, onUpdate));
    _controllers.add(StateControllerWrapped(controller, false, tag));
    return controller;
  }

  List<Pair<Object?, void Function()>> stateUpdaters = [];

  void update([List<Object>? ids]) {
    if (ids == null) {
      for (var element in stateUpdaters) {
        element.right();
      }
    } else {
      for (var element in stateUpdaters) {
        if (ids.contains(element.left)) {
          element.right();
        }
      }
    }
  }

  void dispose() {
    _controllers.removeWhere((element) => element.controller == this);
  }

  void refresh() {
    update();
  }
}

class StateControllerWrapped {
  StateController controller;
  bool autoRemove;
  Object? tag;

  StateControllerWrapped(this.controller, this.autoRemove, this.tag);
}

class StateBuilder<T extends StateController> extends StatefulWidget {
  const StateBuilder(
      {super.key,
      this.init,
      this.dispose,
      this.initState,
      this.tag,
      required this.builder,
      this.id});

  final T? init;

  final void Function(T controller)? dispose;

  final void Function(T controller)? initState;

  final Object? tag;

  final Widget Function(T controller) builder;

  Widget builderWrapped(StateController controller) {
    return builder(controller as T);
  }

  void initStateWrapped(StateController controller) {
    return initState?.call(controller as T);
  }

  void disposeWrapped(StateController controller) {
    return dispose?.call(controller as T);
  }

  final Object? id;

  @override
  State<StateBuilder> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T extends StateController>
    extends State<StateBuilder> {
  late T controller;

  @override
  void initState() {
    if (widget.init != null) {
      StateController.put(widget.init!, tag: widget.tag, autoRemove: true);
    }
    try {
      controller = StateController.find<T>(tag: widget.tag);
    } catch (e) {
      throw "Controller Not Found";
    }
    controller.stateUpdaters.add(Pair(widget.id, () {
      if (mounted) {
        setState(() {});
      }
    }));
    widget.initStateWrapped(controller);
    super.initState();
  }

  @override
  void dispose() {
    widget.disposeWrapped(controller);
    StateController.remove<T>(widget.tag, true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builderWrapped(controller);
}

abstract class StateWithController<T extends StatefulWidget> extends State<T> {
  late final SimpleController _controller;

  void refresh() {
    _controller.update();
  }

  @override
  @mustCallSuper
  void initState() {
    _controller = StateController.putSimpleController(
        () => setState(() {}), tag,
        refresh: refresh);
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void update() {
    _controller.update();
  }

  Object? get tag;
}
