import 'dart:convert';

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';

import '../../commons/logger_tag_commons.dart';
import '../../hive/storage.dart';
import '../../utils/logger_utils.dart';
import '../controller/player_controller.dart';
import 'state/danmaku_state.dart';

class MyDanmakuController {
  final PlayerController playerController;

  MyDanmakuController(this.playerController) {
    state = playerController.danmakuState;
    _initSettings();
  }

  DanmakuController? danmakuController;

  late DanmakuState state;

  bool get videoIsPlaying => playerController.playerState.isPlaying.value;

  BaseDanmakuParser? parser;

  Map<String, dynamic> _settings = {};

  static const List<String> settingsKeys = [
    "danmakuAlphaRatio",
    "danmakuArea",
    "danmakuFontSize",
    "danmakuSpeed",
    "danmakuFilterTypeList",
    "adjustTime",
    "isVisible",
  ];

  void _initSettings() {
    var danmakuSettings = GStorage.setting.get(
      "${SettingBoxKey.cachePrev}-${SettingBoxKey.danmakuSettings}",
    );
    if (danmakuSettings != null && danmakuSettings.isNotEmpty) {
      try {
        if (danmakuSettings is Map) {
          if (danmakuSettings is Map<String, dynamic>) {
            _settings = danmakuSettings;
          } else {
            _settings = DataTypeConvertUtils.toMapStrDyMap(danmakuSettings);
          }
        } else {
          _settings = json.decode(danmakuSettings.toString());
        }
        double? danmakuAlphaRatio = _settings["danmakuAlphaRatio"];
        if (danmakuAlphaRatio != null) {
          state.danmakuAlphaRatio.value = state.danmakuAlphaRatio.value
              .copyWith(ratio: danmakuAlphaRatio);
        }

        int? danmakuArea = _settings["danmakuArea"];
        if (danmakuArea != null) {
          state.danmakuArea.value = state.danmakuArea.value.copyWith(
            areaIndex: danmakuArea,
          );
        }

        double? danmakuFontSize = _settings["danmakuFontSize"];
        if (danmakuFontSize != null) {
          state.danmakuFontSize.value = state.danmakuFontSize.value.copyWith(
            fontSize: danmakuFontSize,
          );
        }
        double? danmakuSpeed = _settings["danmakuSpeed"];
        if (danmakuSpeed != null) {
          state.danmakuSpeed.value = state.danmakuSpeed.value.copyWith(
            speed: danmakuSpeed,
          );
        }

        List<String>? danmakuFilterTypeList =
            _settings["danmakuFilterTypeList"];
        if (danmakuFilterTypeList != null) {
          for (var item in state.danmakuFilterTypeList) {
            item.filter.value = danmakuFilterTypeList.contains(item.enName);
          }
        }
        double? adjustTime = _settings["adjustTime"];
        if (adjustTime != null) {
          state.adjustTime.value = adjustTime;
        }
        bool? isVisible = _settings["isVisible"];
        if (isVisible != null) {
          state.isVisible.value = isVisible;
        }
      } catch (_) {}
    }

    for (var key in settingsKeys) {
      var setting = _settings[key];
      if (setting == null) {
        switch (key) {
          case "danmakuAlphaRatio":
            _settings[key] = state.danmakuAlphaRatio.value.ratio;
            break;
          case "danmakuArea":
            _settings[key] = state.danmakuArea.value.areaIndex;
            break;
          case "danmakuFontSize":
            _settings[key] = state.danmakuFontSize.value.fontSize;
            break;
          case "danmakuSpeed":
            _settings[key] = state.danmakuSpeed.value.speed;
            break;
          case "danmakuFilterTypeList":
            List<String> filterTypeList = state.danmakuFilterTypeList
                .where((element) => element.filter.value)
                .map((element) => element.enName)
                .toList();
            _settings[key] = filterTypeList;
            break;
          case "adjustTime":
            _settings[key] = state.adjustTime.value;
            break;
          case "isVisible":
            _settings[key] = state.isVisible.value;
            break;
        }
      }
    }
  }

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

    ever(state.isVisible, (value) {
      if (value) {
        startDanmaku();
      } else {
        pauseDanmaku();
        clearDanmaku();
      }
      _settings["isVisible"] = value;
      _saveSettings();
    });

    ever(state.adjustTime, (value) {
      adjustTime((value * 1000).toInt());
      _settings["adjustTime"] = value;
      _saveSettings();
    });

    ever(state.danmakuAlphaRatio, (value) {
      if (danmakuController == null) {
        return;
      }
      danmakuController!.updateOption(
        (danmakuController?.option ?? DanmakuOption()).copyWith(
          opacity: state.danmakuAlphaRatio.value.ratio / 100.0,
        ),
      );
      _settings["danmakuAlphaRatio"] = value;
      _saveSettings();
    });

    ever(state.danmakuArea, (value) {
      if (danmakuController == null) {
        return;
      }
      danmakuController!.updateOption(
        (danmakuController?.option ?? DanmakuOption()).copyWith(
          area: state
              .danmakuArea
              .value
              .danmakuAreaItemList[state.danmakuArea.value.areaIndex]
              .area,
          massiveMode: !state
              .danmakuArea
              .value
              .danmakuAreaItemList[state.danmakuArea.value.areaIndex]
              .filter,
        ),
      );
      _settings["danmakuArea"] = value;
      _saveSettings();
    });

    ever(state.danmakuFontSize, (value) {
      if (danmakuController == null) {
        return;
      }
      danmakuController!.updateOption(
        (danmakuController?.option ?? DanmakuOption()).copyWith(
          fontSize: state.danmakuFontSize.value.fontSize,
        ),
      );
      _settings["danmakuFontSize"] = value;
      _saveSettings();
    });

    everAll([state.danmakuSpeed, playerController.playerState.playSpeed], (
      value,
    ) {
      if (danmakuController == null) {
        return;
      }
      double speed =
          state.danmakuSpeed.value.speed /
          playerController.playerState.playSpeed.value;
      danmakuController!.updateOption(
        (danmakuController?.option ?? DanmakuOption()).copyWith(
          duration: speed,
        ),
      );

      _settings["danmakuSpeed"] = speed;
      _saveSettings();
    });

    for (var item in state.danmakuFilterTypeList) {
      ever(item.filter, (value) {
        List<String> filterTypeList = state.danmakuFilterTypeList
            .where((element) => element.filter.value)
            .map((element) => element.enName)
            .toList();

        _settings["danmakuFilterTypeList"] = filterTypeList;
        _saveSettings();
      });
    }
  }

  void _saveSettings() {
    GStorage.setting.put(
      "${SettingBoxKey.cachePrev}-${SettingBoxKey.danmakuSettings}",
      _settings,
    );
  }

  void parseDanmakuFile(String path) {
    state.danmakuFileParse.value = false;
    parser ??= BiliDanmakuParser();
    /*parser ??= BiliDanmakuParser(
      options: BiliDanmakuParseOptions(
        parentTag: "i",
        contentTag: "d",
        attrName: "p",
        splitChar: ",",
        fromAssets: true,
      ),
    );*/
    parser!.stateController.stream.listen((event) {
      if (event.status == ParserStatus.completed) {
        state.danmakuFileParse.value = true;
        startDanmaku();
      }
    });
    danmakuController!.parseDanmaku(parser!, path);
  }

  Future<void> initDanmaku() {
    if (state.danmakuView.value == null || danmakuController == null) {
      bool hideScroll = false;
      bool hideTop = false;
      bool hideBottom = false;
      bool hideSpecial = false;
      for (var item in state.danmakuFilterTypeList) {
        if (item.filter.value) {
          switch (item.enName) {
            case "hideScroll":
              hideScroll = true;
              break;
            case "hideTop":
              hideTop = true;
              break;
            case "hideBottom":
              hideBottom = true;
              break;
            case "hideSpecial":
              hideSpecial = true;
              break;
          }
        }
      }

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
            massiveMode: !state
                .danmakuArea
                .value
                .danmakuAreaItemList[state.danmakuArea.value.areaIndex]
                .filter,
            fontSize: state.danmakuFontSize.value.fontSize,
            duration:
                state.danmakuSpeed.value.speed /
                playerController.playerState.playSpeed.value,
            hideSpecial: hideSpecial,
            hideScroll: hideScroll,
            hideTop: hideTop,
            hideBottom: hideBottom,
            adjustMillisecond: (state.adjustTime.value * 1000).toInt(),
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

  void seekToDanmaku(int position) {
    if (danmakuController == null) {
      return;
    }
    danmakuController!.onUpdateStartTime(position);
  }

  void adjustTime(int value) {
    if (danmakuController == null) {
      return;
    }
    danmakuController!.updateOption(
      (danmakuController?.option ?? DanmakuOption()).copyWith(
        adjustMillisecond: value,
      ),
    );
  }
}
