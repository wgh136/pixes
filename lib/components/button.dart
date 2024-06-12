import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';

abstract class BaseButton extends StatelessWidget {
  const BaseButton({this.enabled = true, this.isLoading = false, super.key});

  final bool enabled;

  final bool isLoading;

  Widget buildNormal(BuildContext context);

  Widget buildLoading(BuildContext context);

  Widget buildDisabled(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildLoading(context);
    } else if (enabled) {
      return buildNormal(context);
    } else {
      return buildDisabled(context);
    }
  }
}

class FluentButton extends BaseButton {
  const FluentButton({
    required this.onPressed,
    required this.child,
    this.width,
    super.enabled,
    super.isLoading,
    super.key,
  });

  final void Function() onPressed;

  final Widget child;

  final double? width;

  static const _kFluentButtonPadding = 12.0;

  @override
  Widget buildNormal(BuildContext context) {
    Widget child = this.child;
    if (width != null) {
      child = child.fixWidth(width! - _kFluentButtonPadding * 2);
    }
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget buildLoading(BuildContext context) {
    Widget child = Center(
      widthFactor: 1,
      heightFactor: 1,
      child: const ProgressRing(
        strokeWidth: 1.6,
      ).fixWidth(14).fixHeight(14),
    );
    if (width != null) {
      child = child.fixWidth(width! - _kFluentButtonPadding * 2);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _kFluentButtonPadding, vertical: 6.5),
      decoration: BoxDecoration(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(4)),
      child: child,
    );
  }

  @override
  Widget buildDisabled(BuildContext context) {
    Widget child = Center(
      widthFactor: 1,
      heightFactor: 1,
      child: this.child,
    );
    if (width != null) {
      child = child.fixWidth(width! - _kFluentButtonPadding * 2);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _kFluentButtonPadding, vertical: 6.5),
      decoration: BoxDecoration(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(4)),
      child: child,
    );
  }
}
