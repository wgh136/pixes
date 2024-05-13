import 'dart:ui';

import 'package:flutter/widgets.dart';

class ColorScheme extends InheritedWidget{
  final Brightness brightness;

  const ColorScheme({super.key, required this.brightness, required super.child});

  static ColorScheme of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<ColorScheme>()!;
  }

  bool get _light => brightness == Brightness.light;

  Color get primary => _light ? const Color(0xff00538a) : const Color(0xff9ccaff);

  Color get primaryContainer => _light ? const Color(0xff5fbdff) : const Color(0xff0079c5);

  Color get secondary => _light ? const Color(0xff426182) : const Color(0xffaac9ef);

  Color get secondaryContainer => _light ? const Color(0xffc1dcff) : const Color(0xff1f3f5f);

  Color get tertiary => _light ? const Color(0xff743192) : const Color(0xffebb2ff);

  Color get tertiaryContainer => _light ? const Color(0xffcf9ae8) : const Color(0xff9c58ba);

  Color get outline => _light ? const Color(0xff707883) : const Color(0xff89919d);

  Color get outlineVariant => _light ? const Color(0xffbfc7d3) : const Color(0xff404752);

  Color get errorColor => _light ? const Color(0xffff3131) : const Color(0xfff86a6a);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget is!ColorScheme || brightness != oldWidget.brightness;
  }
}