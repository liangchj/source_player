import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:get/get.dart';

import '../../commons/logger_tag_commons.dart';
import '../../utils/logger_utils.dart';
import '../controller/player_controller.dart';
import 'state/danmaku_state.dart';

class MyDanmakuController extends GetxController {
  final PlayerController playerController;

  MyDanmakuController(this.playerController) {
    state = playerController.danmakuState;
  }

  DanmakuController? danmakuController;

  late DanmakuState state;

  bool get videoIsPlaying => playerController.playerState.isPlaying.value;

  BaseDanmakuParser? parser;

  initEver() {
    ever(state.danmakuFilePath, (value) {
      if (value.isNotEmpty) {
        if (danmakuController != null) {
          parseDanmakuFile(value);
        } else {
          if (playerController.danmakuState.isVisible.value) {
            initDanmaku();
          }
        }
      }
    });
  }

  void parseDanmakuFile(String path) {
    state.danmakuFileParse.value = false;
    parser ??= BiliDanmakuParser(options: BiliDanmakuParseOptions(parentTag: "i",
      contentTag: "d",
      attrName: "p",
      splitChar: ",", fromAssets: true));
    danmakuController?.parseDanmaku(parser!, path);
    parser!.stateController.stream.listen((event) {
      if (event.status == ParserStatus.completed) {
        state.danmakuFileParse.value = true;
        startDanmaku();
      }
    });
  }

  Future<void> initDanmaku() {
    if (state.danmakuView.value == null || danmakuController == null) {
      state.danmakuView(
        DanmakuScreen(
          createdController: (DanmakuController e) {
            danmakuController = e;
            if (!state.danmakuFileParse.value &&
                state.danmakuFilePath.value.isNotEmpty) {
              parseDanmakuFile(state.danmakuFilePath.value);
            }
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
    if (danmakuController == null) {
      await initDanmaku();
      danmakuController?.start(
        playerController.playerState.positionDuration.value.inMilliseconds,
      );
    } else {
      danmakuController?.start(
        playerController.playerState.positionDuration.value.inMilliseconds,
      );
    }
  }

  Future<void> resumeDanmaku() async {
    if (!videoIsPlaying ||
        !state.isVisible.value ||
        danmakuController == null) {
      return;
    }
    if (danmakuController!.started()) {
      danmakuController?.resume();
    } else {
      danmakuController?.start(
        playerController.playerState.positionDuration.value.inMilliseconds,
      );
    }
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

  void restDanmaku() {
    if (danmakuController == null) {
      return;
    }
    try {
      danmakuController!.reset();
    } catch (e) {
      state.errorMsg("重置弹幕失败：$e");
      LoggerUtils.logger.d(
        "${LoggerTagCommons.danmakuLog}restDanmaku，重置弹幕失败：$e",
      );
    }
  }
}
