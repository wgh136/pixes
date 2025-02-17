import 'package:pixes/network/app_dio.dart';

abstract class Translator {
  static Translator? _instance;

  static Translator get instance {
    if (_instance == null) {
      init();
    }
    return _instance!;
  }

  static void init() {
    _instance = GoogleTranslator();
  }

  /// Translates the given [text] to the given [to] language.
  Future<String> translate(String text, String to);
}

class GoogleTranslator implements Translator {
  final Dio _dio = AppDio();

  String get url => 'https://translate.google.com/translate_a/single';

  Map<String, dynamic> buildBody(String text, String to) {
    return {
      'q': text,
      'client': 'at',
      'sl': 'auto',
      'tl': to,
      'dt': 't',
      'ie': 'UTF-8',
      'oe': 'UTF-8',
      'dj': '1',
    };
  }

  Future<String> translatePart(String part, String to) async {
    final response = await _dio.post(
      url,
      data: buildBody(part, to),
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        },
      ),
    );
    var buffer = StringBuffer();
    for (var e in response.data['sentences']) {
      buffer.write(e['trans']);
    }
    return buffer.toString();
  }

  @override
  Future<String> translate(String text, String to) async {
    final lines = text.split('\n');
    var buffer = StringBuffer();
    var result = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (buffer.length + line.length > 5000) {
        result += await translatePart(buffer.toString(), to);
        buffer.clear();
      }
      buffer.write(line);
      buffer.write('\n');
    }
    if (buffer.isNotEmpty) {
      result += await translatePart(buffer.toString(), to);
    }
    return result;
  }
}
