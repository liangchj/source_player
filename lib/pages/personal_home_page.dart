import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xml/xml.dart';

import '../models/media_file_model.dart';
import '../models/resource_chapter_model.dart';
import '../player/controller/player_controller.dart';
import '../player/utils/player_utils.dart';
import '../utils/logger_utils.dart';

class PersonalHomePage extends StatefulWidget {
  const PersonalHomePage({super.key});

  @override
  State<PersonalHomePage> createState() => _PersonalHomePageState();
}

class _PersonalHomePageState extends State<PersonalHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(onPressed: () => _loadDanmaku(), child: Text("个人中心")),
          TextButton(
            onPressed: () {
              Get.delete<PlayerController>();
              List<ResourceChapterModel> chapterList = [
                ResourceChapterModel(
                  name: '1',
                  index: 0,
                  playUrl: "asset://assets/video/test.mp4",
                  mediaFileModel: MediaFileModel(
                    danmakuPath: "assets/danmaku/1.xml",
                  ),
                )
              ];
              PlayerUtils.openLocalVideo(
                chapterList: chapterList,
                playerControllerCallback: (controller) {
                  // playerController = controller;
                },
              );
            },
            child: Text("测试播放视频"),
          ),
        ],
      ),
    );
  }

  /*testReadXml() async {
    print("读取xml");
    String data = await rootBundle.loadString('assets/danmaku/1.xml');
    // print(data);
    final document = XmlDocument.parse(data);
    print(document.rootElement.name);
    var allElements = document.findAllElements("p");
    for (var element in allElements) {
      print(element.attributes);
      print(element.innerText);
    }
  }*/
  List<DanmakuItem> danmakuList = [];
  Future<void> _loadDanmaku() async {
    try {
      var start = DateTime.now();
      final data = await rootBundle.loadString('assets/danmaku/1.xml');
      // 使用compute将解析工作放到后台isolate中
      final result = await compute(parseDanmaku, data);
      var end = DateTime.now();
      LoggerUtils.logger.d("解析弹幕耗时: ${end.difference(start)}");
      LoggerUtils.logger.d("结果：");
      for (var item in result) {
        LoggerUtils.logger.d(item);
      }
    } catch (e) {
      LoggerUtils.logger.d("读取弹幕失败: $e");
    }
  }


}

// 在isolate中运行的解析函数
List<DanmakuItem> parseDanmaku(String xmlString) {
  final document = XmlDocument.parse(xmlString);
  final elements = document.findAllElements("d");
  final List<DanmakuItem> danmakus = [];

  for (final element in elements) {
    final pAttribute = element.getAttribute("p");
    if (pAttribute != null) {
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

          danmakus.add(DanmakuItem(
            time: time,
            mode: mode,
            size: size,
            color: color,
            timestamp: timestamp,
            pool: pool,
            senderId: senderId,
            rowId: rowId,
            text: text,
          ));
        } catch (e) {
          // 忽略解析错误的条目
          continue;
        }
      }
    }
  }

  return danmakus;
}

// 弹幕数据模型
class DanmakuItem {
  final double time;      // 弹幕出现时间(秒)
  final int mode;         // 弹幕模式
  final int size;         // 字体大小
  final int color;        // 颜色
  final int timestamp;    // 时间戳
  final String pool;      // 弹幕池
  final String senderId;  // 发送者ID
  final String rowId;     // 弹幕行ID
  final String text;      // 弹幕文本

  DanmakuItem({
    required this.time,
    required this.mode,
    required this.size,
    required this.color,
    required this.timestamp,
    required this.pool,
    required this.senderId,
    required this.rowId,
    required this.text,
  });
  @override
  String toString() {
    return 'DanmakuItem(time: $time, text: $text)';
  }
}
