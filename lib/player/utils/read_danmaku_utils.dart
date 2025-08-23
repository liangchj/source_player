import 'dart:io';

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:xml/xml.dart';

class ReadDanmakuUtils {
  static Future<List<DanmakuItem>> parseDanmakuByFile(File file) async {
    if (!file.existsSync()) {
      return [];
    }
    final document = XmlDocument.parse(file.readAsStringSync());
    final elements = document.findAllElements("d");
    final List<DanmakuItem> danmakus = [];
    for (final element in elements) {
      final pAttribute = element.getAttribute("p");
      if (pAttribute == null) {
        continue;
      }
      final parts = pAttribute.split(",");
      if (parts.length >= 8) {
        try {
          final time = double.parse(parts[0]);
          final mode = int.parse(parts[1]);
          final size = int.parse(parts[2]);
          final color = int.parse(parts[3]);
          final timestamp = int.parse(parts[4]);
          final pool = parts[5];
          final senderId = parts[6];
          final rowId = parts[7];
          final text = element.innerText;

         
        } catch (e) {
          // 忽略解析错误的条目
          continue;
        }
      }
    }

    return [];
  }
}
