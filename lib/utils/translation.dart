import 'package:pixes/foundation/app.dart';

extension Translation on String {
  String get tl {
    var locale = App.locale;
    return translation["${locale.languageCode}_${locale.countryCode}"]?[this] ??
        this;
  }

  static const translation = <String, Map<String, String>>{
    "zh_CN": {},
    "zh_TW": {},
  };
}
