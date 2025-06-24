
class MapDataUtils {
  // 提取第一个数值（整数或小数）
  static String? extractFirstNumericValue(String input) {
    final regex = RegExp(r'[-+]?\d*\.?\d+');
    final match = regex.firstMatch(input);
    return match?.group(0);
  }

  // 提取所有数值（整数或小数）
  static List<String> extractAllNumericValues(String input) {
    final regex = RegExp(r'[-+]?\d*\.?\d+');
    return regex.allMatches(input).map((m) => m.group(0)!).toList();
  }

  static double? getDoubleFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    double? d = double.tryParse(str);
    if (d != null) {
      return d;
    }
    var numStr = extractFirstNumericValue(str);
    return numStr == null ? null : double.tryParse(numStr);

  }
  static Duration? getDurationFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    double? d = double.tryParse(str);
    if (d != null) {
      return Duration(milliseconds: (d * 60 * 1000).ceil());
    }
    return null;
    /*try {
      var parse = int.parse(value);
      return parse;
    } catch (e) {
      throw Exception("将json数据中的$key转换为int类型报错：$e");
    }*/
  }

  static int? getIntFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    try {
      var parse = int.parse(str);
      return parse;
    } catch (e) {
      throw Exception("将json数据中的[$key]：$str转换为int类型报错：$e");
    }
  }

  static List<String> getListFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value != null) {
      String str = value.toString().trim();
      if (str.isEmpty) {
        return [];
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else {
        return value.toString().split(",");
      }
    } else {
      return [];
    }
  }
}