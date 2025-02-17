import 'package:flutter/material.dart' as md;

typedef MdIcons = md.Icons;
typedef MdTheme = md.Theme;
typedef MdThemeData = md.ThemeData;
typedef MdColorScheme = md.ColorScheme;
typedef TextField = md.TextField;

class ColorScheme {
  static md.ColorScheme of(md.BuildContext context) {
    return md.Theme.of(context).colorScheme;
  }
}
