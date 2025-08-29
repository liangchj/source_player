import 'dart:convert';
import 'dart:io';

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:source_player/player/exception/read_file_exception.dart';
import 'package:source_player/utils/logger_utils.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../models/danmaku_item_model.dart';

class BiliDanmakuParseOptions {
  final String xmlPath;
  final String? parentTag;
  final String? contentTag;
  final String? attrName;
  final String? splitChar;
  final bool fromAssets;
  final String? xpath;

  BiliDanmakuParseOptions({
    required this.xmlPath,
    this.parentTag,
    this.contentTag,
    this.attrName,
    this.splitChar,
    this.fromAssets = false,
    this.xpath,
  });
  BiliDanmakuParseOptions copyWith({
    String? xmlPath,
    String? parentTag,
    String? contentTag,
    String? attrName,
    String? splitChar,
    String? xpath,
    bool? fromAssets,
  }) {
    return BiliDanmakuParseOptions(
      xmlPath: xmlPath ?? this.xmlPath,
      parentTag: parentTag ?? this.parentTag,
      contentTag: contentTag ?? this.contentTag,
      attrName: attrName ?? this.attrName,
      splitChar: splitChar ?? this.splitChar,
      xpath: xpath ?? this.xpath,
      fromAssets: fromAssets ?? this.fromAssets,
    );
  }
}

class BiliDanmakuParse {
  static const String parentTagName = "i";
  static const String contentTagName = "d";
  static const String readAttrName = "p";
  static const String readAttrSplitChar = ",";
  // 最少只需要读取到颜色
  static const int readAttrMinLen = 4;
  static const String xpathParseXml = "//i//d[@p and not(*)]";
  static BiliDanmakuParse? _instance;

  BiliDanmakuParse._();

  factory BiliDanmakuParse() {
    _instance = _instance ?? BiliDanmakuParse._();
    return _instance!;
  }
  Future<XmlDocument?> readXmlFromAssets(String xmlPath) async {
    String xmlStr = await rootBundle.loadString(xmlPath);
    if (xmlStr.isEmpty) {
      return Future.value(null);
    }
    XmlDocument document = XmlDocument.parse(xmlStr);
    return document;
  }

  XmlDocument? readXmlFromPath(String xmlPath) {
    try {
      var file = File(xmlPath);
      if (!file.existsSync()) {
        LoggerUtils.logger.e("弹幕文件已不存在：$xmlPath");
        throw ReadFileException("弹幕文件已不存在");
      }
      String xmlStr = File(xmlPath).readAsStringSync();
      if (xmlStr.isEmpty) {
        return null;
      }

      XmlDocument document = XmlDocument.parse(xmlStr);
      return document;
    } on PathAccessException catch (e) {
      LoggerUtils.logger.e("弹幕文件访问权限不足，文件：$xmlPath，错误：$e");
      throw ReadFileException("弹幕文件访问权限不足");
    } on FileSystemException catch (e) {
      LoggerUtils.logger.e("弹幕文件系统错误，文件：$xmlPath，错误：$e");
      // 处理文件系统相关异常
      throw ReadFileException("弹幕文件系统错误");
    } catch (e) {
      LoggerUtils.logger.e("弹幕解析错误，文件：$xmlPath，错误：$e");
      // 处理其他异常
      throw ReadFileException("弹幕解析错误");
    }
  }

  // xpath方式读取（文件内容多会很慢，推荐使用逐级方式读取）
  Future<Map<double, List<DanmakuItemModel>>> parseDanmakuByXmlForXpath(
    BiliDanmakuParseOptions options,
  ) async {
    XmlDocument? document;
    if (options.fromAssets) {
      document = await readXmlFromAssets(options.xmlPath);
    } else {
      document = readXmlFromPath(options.xmlPath);
    }
    if (document == null) {
      return {};
    }
    Map<double, List<DanmakuItemModel>> danmakuMap = {};
    if (document.childElements.isNotEmpty) {
      Iterable<XmlNode> iterable = document.xpath(
        options.xpath ?? xpathParseXml,
      );
      for (XmlNode xmlNode in iterable) {
        String readAttrText = xmlNode.getAttribute(
          options.attrName ?? readAttrName,
        )!;
        List<String> readAttrTextList = readAttrText.split(
          options.splitChar ?? readAttrSplitChar,
        );
        if (readAttrTextList.isEmpty ||
            readAttrTextList.length < readAttrMinLen ||
            xmlNode.innerText.isEmpty) {
          continue;
        }

        DanmakuItemModel? danmakuItem = createDanmakuModel(
          readAttrTextList,
          xmlNode.innerText,
        );
        if (danmakuItem != null) {
          var duration = Duration(milliseconds: danmakuItem.time);
          var inSeconds = duration.inSeconds;
          var inMilliseconds = duration.inMilliseconds;
          var balance = inMilliseconds - inSeconds * 1000;
          double key = inSeconds + (balance >= 500 ? 0.5 : 0);
          var list = danmakuMap[key] ?? [];
          list.add(danmakuItem);
          danmakuMap[key] = list;
        }
      }
    }
    return danmakuMap;
  }

  // 逐级方式读取
  Future<Map<double, List<DanmakuItemModel>>> parseDanmakuByXml(
    BiliDanmakuParseOptions options,
  ) async {
    XmlDocument? document;
    if (options.fromAssets) {
      document = await readXmlFromAssets(options.xmlPath);
    } else {
      document = readXmlFromPath(options.xmlPath);
    }
    Map<double, List<DanmakuItemModel>> danmakuMap = {};
    if (document == null) {
      return danmakuMap;
    }
    for (XmlElement xmlElement in document.childElements) {
      // 需要是指定（i）标签下的
      if (xmlElement.localName == (options.parentTag ?? parentTagName)) {
        for (XmlElement element in xmlElement.childElements) {
          DanmakuItemModel? danmakuItem = getDanmakuItemByXmlElement(
            element,
            parentTag: options.parentTag,
            contentTag: options.contentTag,
            attrName: options.attrName,
            splitChar: options.splitChar,
          );
          if (danmakuItem != null) {
            var duration = Duration(milliseconds: danmakuItem.time);
            var inSeconds = duration.inSeconds;
            var inMilliseconds = duration.inMilliseconds;
            var balance = inMilliseconds - inSeconds * 1000;
            double key = inSeconds + (balance >= 500 ? 0.5 : 0);
            var list = danmakuMap[key] ?? [];
            list.add(danmakuItem);
            danmakuMap[key] = list;
          }
        }
      } else {
        DanmakuItemModel? danmakuItem = getDanmakuItemByXmlElement(
          xmlElement,
          parentTag: options.parentTag,
          contentTag: options.contentTag,
          attrName: options.attrName,
          splitChar: options.splitChar,
        );
        if (danmakuItem != null) {
          var duration = Duration(milliseconds: danmakuItem.time);
          var inSeconds = duration.inSeconds;
          var inMilliseconds = duration.inMilliseconds;
          var balance = inMilliseconds - inSeconds * 1000;
          double key = inSeconds + (balance >= 500 ? 0.5 : 0);
          var list = danmakuMap[key] ?? [];
          list.add(danmakuItem);
          danmakuMap[key] = list;
        }
      }
    }
    return danmakuMap;
  }

  DanmakuItemModel? getDanmakuItemByXmlElement(
    XmlElement element, {
    String? parentTag,
    String? contentTag,
    String? attrName,
    String? splitChar,
  }) {
    // 只读取指定（d）标签，且没有子节点，内容不为空，有指定属性
    if (element.localName != (contentTag ?? contentTagName) ||
        element.childElements.isNotEmpty ||
        element.getAttribute(attrName ?? readAttrName) == null ||
        element.innerText.isEmpty) {
      return null;
    }
    String readAttrText = element.getAttribute(attrName ?? readAttrName)!;
    List<String> readAttrTextList = readAttrText.split(
      splitChar ?? readAttrSplitChar,
    );
    // 属性长度
    if (readAttrTextList.isEmpty || readAttrTextList.length < readAttrMinLen) {
      return null;
    }
    return createDanmakuModel(readAttrTextList, element.innerText);
  }

  /// 流式解析本地文件
  Stream<DanmakuItemModel> parseLocalFileAsStream(String filePath) async* {
    final file = File(filePath);
    if (!await file.exists()) {
      return;
    }

    try {
      final lines = file
          .openRead()
          .transform(utf8.decoder)
          .transform(LineSplitter());
      await for (String line in lines) {
        final danmakuItem = _parseLine(line.trim());
        if (danmakuItem != null) {
          yield danmakuItem;
        }
      }
    } catch (e) {
      throw Exception('流式解析出错: $e');
    }
  }

  /// 流式解析 Assets 文件
  Stream<DanmakuItemModel> parseAssetsFileAsStream(
    String assetPath,
    Future<String> Function(String) loadString,
  ) async* {
    try {
      final content = await loadString(assetPath);
      final lines = LineSplitter().convert(content);

      for (String line in lines) {
        final danmakuItem = _parseLine(line.trim());
        if (danmakuItem != null) {
          yield danmakuItem;
        }
      }
    } catch (e) {
      throw Exception('流式解析 Assets 出错: $e');
    }
  }

  /// 解析单行弹幕数据
  DanmakuItemModel? _parseLine(String line) {
    // 匹配 <d p="...">content</d> 格式
    final RegExp danmakuRegex = RegExp(r'<d p="([^"]*)">(.*?)</d>');
    final match = danmakuRegex.firstMatch(line);

    if (match == null) {
      return null;
    }

    final String attrString = match.group(1) ?? '';
    final String content = match.group(2) ?? '';

    if (attrString.isEmpty || content.isEmpty) {
      return null;
    }

    final List<String> attrs = attrString.split(',');
    if (attrs.length < 4) {
      return null;
    }

    try {
      final double time = double.parse(attrs[0]);
      final int mode = int.parse(attrs[1]);
      final double fontSize = double.parse(attrs[2]);
      final int colorValue = int.parse(attrs[3]);

      DanmakuItemType danmakuItemType;
      switch (mode) {
        case 4:
          danmakuItemType = DanmakuItemType.bottom;
          break;
        case 5:
          danmakuItemType = DanmakuItemType.top;
          break;
        default:
          danmakuItemType = DanmakuItemType.scroll;
      }

      return DanmakuItemModel(
        content,
        type: danmakuItemType,
        color: Color(colorValue | 0xFF000000),
        time: Duration(milliseconds: (time * 1000).floor()).inMilliseconds,
        fontSize: fontSize,
        danmakuId: '$time-$content',
        level: 0,
      );
    } catch (e) {
      // 解析失败，跳过该条弹幕
      return null;
    }
  }

  // 生成弹幕内容
  DanmakuItemModel? createDanmakuModel(
    List<String> readAttrTextList,
    String text,
  ) {
    // <d p="490.19100,1,25,16777215,1584268892,0,a16fe0dd,29950852386521095">从结尾回来看这里，更感动了！</d>
    // 0 视频内弹幕出现时间	float	秒

    // 1 弹幕类型	int32	1 2 3：普通弹幕
    //                  4：底部弹幕
    //                  5：顶部弹幕
    //                  6：逆向弹幕
    //                  7：高级弹幕
    //                  8：代码弹幕
    //                  9：BAS弹幕（pool必须为2）

    // 2	弹幕字号	int32	18：小
    //                  25：标准
    //                  36：大

    // 3	弹幕颜色	int32	十进制RGB888值

    // 4	弹幕发送时间	int32	时间戳

    // 5	弹幕池类型	int32	0：普通池
    //                      1：字幕池
    //                      2：特殊池（代码/BAS弹幕）

    // 6	发送者mid的HASH	string	用于屏蔽用户和查看用户发送的所有弹幕 也可反查用户id
    // 7	弹幕dmid	int64	唯一 可用于操作参数
    // 8	弹幕的屏蔽等级	int32	0-10，低于用户设定等级的弹幕将被屏蔽 （新增，下方样例未包含）
    double? time;
    // 	弹幕类型
    int? mode;
    DanmakuItemType? danmakuItemType;
    // 弹幕字号
    double? fontSize;
    // 弹幕颜色（十进制RGB888值）
    int? color;
    // 弹幕发送时间	时间戳
    int? createTime;
    // 弹幕池类型
    String? poolType;
    // 发送者mid的HASH	string	用于屏蔽用户和查看用户发送的所有弹幕 也可反查用户id
    String? sendUserId;
    // 弹幕dmid	int64	唯一 可用于操作参数
    String? danmakuId;
    // 弹幕的屏蔽等级
    late int level;
    for (int i = 0; i < readAttrTextList.length; i++) {
      if (i > 9) {
        return null;
      }
      String value = readAttrTextList[i].trim();
      try {
        switch (i) {
          case 0:
            time = double.parse(value);
            break;
          case 1:
            mode = int.tryParse(value) ?? 1;
            break;
          case 2:
            fontSize = double.parse(value);
            if (fontSize <= 0) {
              return null;
            }
            break;
          case 3:
            color = int.parse(value);
            break;
          case 4:
            createTime = int.tryParse(value);
            break;
          case 5:
            poolType = value;
            break;
          case 6:
            sendUserId = value;
            break;
          case 7:
            danmakuId = value;
            break;
          case 8:
            level = int.parse(value);
            break;
        }
      } catch (e) {
        return null;
      }
    }

    if (time == null) {
      return null;
    }

    switch (mode) {
      case 4:
        danmakuItemType = DanmakuItemType.bottom;
        break;
      case 5:
        danmakuItemType = DanmakuItemType.top;
        break;
      default:
        danmakuItemType = DanmakuItemType.scroll;
    }
    return DanmakuItemModel(
      text,
      type: danmakuItemType,
      color: color == null ? Colors.white : Color(color | 0xFF000000),
      time: Duration(milliseconds: (time * 1000).floor()).inMilliseconds,
      fontSize: fontSize,
      createTime: createTime,
      poolType: poolType,
      sendUserId: sendUserId,
      danmakuId: danmakuId ?? "$time - $text",
      level: level,
    );
  }
}
