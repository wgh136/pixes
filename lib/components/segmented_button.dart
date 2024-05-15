import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';

import 'md.dart';

class SegmentedButton<T> extends StatelessWidget {
  const SegmentedButton(
      {required this.options,
      required this.value,
      required this.onPressed,
      super.key});

  final List<SegmentedButtonOption<T>> options;

  final T value;

  final void Function(T key) onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((e) => buildButton(e)).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildButton(SegmentedButtonOption<T> e) {
    bool active = value == e.key;
    return HoverButton(
        cursor: active ? MouseCursor.defer : SystemMouseCursors.click,
        onPressed: () => onPressed(e.key),
        builder: (context, states) {
          var textColor = active ? null : ColorScheme.of(context).outline;
          var backgroundColor = active ? null : ButtonState.resolveWith((states) {
            return ButtonThemeData.buttonColor(context, states);
          }).resolve(states);

          return Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                border: e != options.last
                    ? Border(
                        right: BorderSide(
                            width: 0.6,
                            color: ColorScheme.of(context).outlineVariant))
                    : null),
            child: Center(
              child: Text(e.text,
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w500))
                  .paddingHorizontal(12),
            ),
          );
        });
  }
}

class SegmentedButtonOption<T> {
  final T key;
  final String text;

  const SegmentedButtonOption(this.key, this.text);
}
