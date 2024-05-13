import 'package:flutter/material.dart' as md;

typedef MdIcons = md.Icons;

class ColorScheme {
  static md.ColorScheme of(md.BuildContext context) {
    return md.Theme.of(context).colorScheme;
  }
}