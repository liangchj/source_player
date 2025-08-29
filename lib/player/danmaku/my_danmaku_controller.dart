import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:source_player/models/resource_chapter_model.dart';

import '../../commons/logger_tag_commons.dart';
import '../../utils/logger_utils.dart';
import '../controller/player_controller.dart';
import '../enums/player_ui_key_enum.dart';
import '../exception/read_file_exception.dart';
import 'models/danmaku_item_model.dart';
import 'parse/bili_danmaku_parse.dart';
import 'state/danmaku_state.dart';

class MyDanmakuController {
  final PlayerController playerController;
  final DanmakuState state;

  MyDanmakuController(this.playerController, this.state);

  DanmakuController? danmakuController;

  bool get videoIsPlaying => playerController.playerState.isPlaying.value;

  initEver() {
    everAll(
      [
        state.danmakuAlphaRatio,
        state.danmakuArea,
        state.danmakuFontSize,
        state.danmakuSpeed,
      ],
      (value) {
        if (danmakuController == null) {
          return;
        }
        DanmakuOption option = danmakuController!.option.copyWith(
          opacity: state.danmakuAlphaRatio.value.ratio / 100.0,
          area: state
              .danmakuArea
              .value
              .danmakuAreaItemList[state.danmakuArea.value.areaIndex]
              .area,
          fontSize: state.danmakuFontSize.value.fontSize,
          duration: state.danmakuSpeed.value.speed,
        );
        danmakuController!.updateOption(option);
      },
    );
  }

  // 读取弹幕文件
  Future<void> readDanmakuListByFilePath({bool readAll = true}) async {
    LoggerUtils.logger.d("${LoggerTagCommons.danmakuLog}，进入读取弹幕文件内容");
    if (!videoIsPlaying || !state.isVisible.value) {
      return;
    }
    if (state.danmakuFilePathMap.value == null ||
        state.danmakuFilePathMap.value!.isEmpty) {
      return;
    }
    List<String> parseErrorList = [];
    Map<double, List<DanmakuItemModel>> danmakuMap = readAll
        ? {}
        : state.danmakuMap.value;
    for (var entry in state.danmakuFilePathMap.value!.entries) {
      if (!readAll && entry.value) {
        continue;
      }
      try {
        var map = await compute(
          BiliDanmakuParse().parseDanmakuByXml,
          BiliDanmakuParseOptions(xmlPath: entry.key, fromAssets: false),
        );
        if (map.isNotEmpty) {
          if (readAll || danmakuMap.isEmpty) {
            danmakuMap.addAll(map);
          } else {
            for (var en in map.entries) {
              var list = danmakuMap[en.key] ?? [];
              list.addAll(en.value);
              danmakuMap[en.key] = list;
            }
          }
        }
      } on ReadFileException catch (e) {
        parseErrorList.add(e.message);
        LoggerUtils.logger.d(
          "${LoggerTagCommons.danmakuLog}，弹幕文件解析失败：${entry.key}，错误信息：$e",
        );
      } on Exception catch (e) {
        parseErrorList.add(e.toString());
        LoggerUtils.logger.d(
          "${LoggerTagCommons.danmakuLog}，弹幕文件解析失败：${entry.key}，错误信息：$e",
        );
      }
      state.danmakuFilePathMap.value![entry.key] = true;
    }
    state.danmakuMap.value = danmakuMap;
    if (parseErrorList.isNotEmpty) {
      playerController.uiState.bottomLeftMsg.value = parseErrorList.join(', ');
      playerController.onlyShowUIByKeyList([
        PlayerUIKeyEnum.leftBottomHitUI.name,
        PlayerUIKeyEnum.restartUI.name,
      ], ignoreLimit: true);
    }
  }

  Future<void> initDanmaku() {
    if (state.danmakuView.value == null || danmakuController == null) {
      state.danmakuView(
        DanmakuScreen(
          createdController: (DanmakuController e) {
            danmakuController = e;
          },
          option: (danmakuController?.option ?? DanmakuOption()).copyWith(
            opacity: state.danmakuAlphaRatio.value.ratio / 100.0,
            area: state
                .danmakuArea
                .value
                .danmakuAreaItemList[state.danmakuArea.value.areaIndex]
                .area,
            fontSize: state.danmakuFontSize.value.fontSize,
            duration: state.danmakuSpeed.value.speed,
          ),
        ),
      );
      return Future.value();
    }
    return Future.value();
  }

  Future<void> startDanmaku() async {
    if (!videoIsPlaying || !state.isVisible.value) {
      return;
    }
    await initDanmaku();
    if (!state.allPathReady) {
      await readDanmakuListByFilePath(readAll: false);
    }
    if (danmakuController != null) {
      danmakuController!.resume();
    }
  }

  Future<void> resumeDanmaku() async {
    if (!videoIsPlaying || !state.isVisible.value) {
      return;
    }
    if (danmakuController == null ||
        !danmakuController!.running ||
        !state.allPathReady ||
        state.danmakuMap.value.isEmpty) {
      await startDanmaku();
      return;
    }
    danmakuController!.resume();
  }

  // 暂停弹幕
  void pauseDanmaku() {
    if (danmakuController == null || !danmakuController!.running) {
      return;
    }
    try {
      danmakuController!.pause();
    } catch (e) {
      state.errorMsg("暂停弹幕失败：$e");
      LoggerUtils.logger.d(
        "${LoggerTagCommons.danmakuLog}pauseDanmaku，暂停弹幕失败：$e",
      );
    }
  }

  void stopDanmaku() {
    if (danmakuController == null) {
      return;
    }
    try {
      danmakuController!.clear();
      danmakuController!.pause();
    } catch (e) {
      state.errorMsg("停止弹幕失败：$e");
      LoggerUtils.logger.d(
        "${LoggerTagCommons.danmakuLog}stopDanmaku，停止弹幕失败：$e",
      );
    }
  }

  void clearDanmaku() {
    if (danmakuController == null) {
      return;
    }
    try {
      danmakuController!.clear();
    } catch (e) {
      state.errorMsg("清空弹幕失败：$e");
      LoggerUtils.logger.d(
        "${LoggerTagCommons.danmakuLog}clearDanmaku，清空弹幕失败：$e",
      );
    }
  }

  // 发送弹幕
  void sendDanmakuByPosition(Duration value) {
    if (danmakuController == null ||
        !videoIsPlaying ||
        playerController.playerState.isSeeking.value ||
        !state.isVisible.value ||
        state.danmakuMap.value.isEmpty) {
      return;
    }
    var inSeconds = value.inSeconds;
    var inMilliseconds = value.inMilliseconds;
    // 添加时间合理性检查
    var currentPosition = playerController.playerState.positionDuration.value;
    if (currentPosition.inMilliseconds != inMilliseconds) {
      // 时间不匹配，可能是过时的事件
      return;
    }
    var balance = inMilliseconds - (inSeconds * 1000);
    double time = inSeconds + (balance >= 500 ? 0.0 : 0.5);

    if (state.prevSendSecond == time) {
      return;
    }
    var list = state.danmakuMap.value[time] ?? [];
    if (list.isEmpty) {
      return;
    }
    list.sort((a, b) => b.time.compareTo(a.time));
    for (var item in list) {
      sendDanmaku(item);
    }
  }

  void sendDanmaku(DanmakuItemModel item) {
    if (danmakuController == null ||
        !videoIsPlaying ||
        playerController.playerState.isSeeking.value ||
        !state.isVisible.value) {
      return;
    }
    danmakuController!.addDanmaku(
      DanmakuContentItem(item.text, color: item.color, type: item.type),
    );
  }

  void beforeChangePlayUrl() {
    stopDanmaku();
    state.prevSendSecond = -1;
    state.danmakuFilePathMap.value = {};
    state.danmakuMap.value = {};
  }

  void afterChangePlayUrl(ResourceChapterModel? activatedChapter) {
    String danmakuFilePath = "";
    if (activatedChapter != null && activatedChapter.mediaFileModel != null) {
      danmakuFilePath = activatedChapter.mediaFileModel!.danmakuPath ?? "";
    }

    stopDanmaku();
    state.prevSendSecond = -1;
    state.danmakuFilePathMap.value = danmakuFilePath.isEmpty
        ? {}
        : {danmakuFilePath: false};
    state.danmakuMap.value = {};
  }
}
