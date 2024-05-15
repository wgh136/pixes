import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pixes/foundation/app.dart';

extension Translation on String {
  String get tl {
    var locale = App.locale;
    return translation["${locale.languageCode}_${locale.countryCode}"]?[this] ??
        this;
  }

  static late final Map<String, Map<String, dynamic>> translation;

  static Future<void> init() async{
    var data = await rootBundle.loadString("assets/tr.json");
    translation = Map<String, Map<String, dynamic>>.from(jsonDecode(data));
  }
}
