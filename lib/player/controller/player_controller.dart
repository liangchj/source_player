import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/danmaku/my_danmaku_controller.dart';
import 'package:source_player/player/iplayer.dart';
import 'package:source_player/player/state/player_ui_state.dart';
import 'package:source_player/player/ui/fullscreen_source_ui.dart';
import 'package:source_player/utils/logger_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../commons/icon_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../hive/hive_models/history/play_history.dart';
import '../../hive/hive_models/resource/episodeInfo.dart';
import '../../hive/hive_models/resource/video_resource.dart';
import '../../hive/storage.dart';
import '../../utils/bottom_sheet_dialog_utils.dart';
import '../commons/player_commons.dart';
import '../danmaku/state/danmaku_state.dart';
import '../enums/player_ui_key_enum.dart';
import '../models/bottom_ui_control_item_model.dart';
import '../models/player_overlay_ui_model.dart';
import '../state/player_state.dart';
import '../state/resource_play_state.dart';
import '../ui/danmaku_setting_ui.dart';
import '../ui/fullscreen_chapter_list_ui.dart';
import '../ui/player_speed_ui.dart';
import '../utils/fullscreen_utils.dart';

class PlayerController extends GetxController {
  var player = Rx<IPlayer?>(null);

  NetResourceDetailController? netResourceDetailController;

  late ResourcePlayState resourcePlayState;

  PlayerController();

  late PlayerState playerState;

  late PlayerUIState uiState;

  bool isWeb = kIsWeb;

  late FullscreenUtils fullscreenUtils;

  // 标记是否只有全屏页面
  bool onlyFullscreen = false;

  List<PlayerBottomUIItemModel> fullscreenBottomUIItemList = [];

  Timer? hideTimer;

  bool _initialized = false;

  late DanmakuState danmakuState;
  late MyDanmakuController myDanmakuController;

  final RxBool interceptPop = false.obs;

  Timer? _historyRecordTimer;

  Duration startPlayDuration = Duration.zero;

  static const int HISTORY_RECORD_INTERVAL = 15; // 15秒记录一次
  static const int MIN_PLAY_TIME_FOR_HISTORY = 5; // 至少播放5秒才记录

  @override
  void onInit() {
    resourcePlayState = ResourcePlayState();
    playerState = PlayerState();

    double? playSpeed = GStorage.setting.get(
      "${SettingBoxKey.cachePrev}-${SettingBoxKey.playSpeed}",
    );
    if (playSpeed != null) {
      playerState.playSpeed.value = playSpeed;
    }
    uiState = PlayerUIState();
    fullscreenUtils = FullscreenUtils(this);
    danmakuState = DanmakuState();
    myDanmakuController = MyDanmakuController(this);
    _initEver();

    _initBottomControlItemList();
    _initUI();
    super.onInit();
    _initialized = true;
  }

  _initUI() {
    uiState.restartUI.ui.value = Container(
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Obx(() {
          if (!(resourcePlayState.activatedChapter == null ||
              resourcePlayState.activatedChapter!.historyDuration == null)) {
            return Container();
          }
          return TextButton(
            onPressed: () {},
            child: Text('重新开始播放', style: TextStyle(color: Colors.white)),
          );
        }),
      ),
    );
    uiState.leftBottomHitUI.ui.value = Container(
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      child: Align(
        alignment: Alignment.topLeft,
        child: Obx(
          () =>
              uiState.bottomLeftMsg.value == null ||
                  uiState.bottomLeftMsg.value!.isEmpty
              ? Container()
              : Text(
                  uiState.bottomLeftMsg.value!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );

    uiState.settingsUIMap["resourceChapterList"] = [
      if (resourcePlayState.activatedChapterList.length > 1)
        InkWell(
          onTap: () {
            hideCanControlUI();
            BottomSheetDialogUtils.closeBottomSheet();
            if (Get.size.width < Get.size.height) {
              BottomSheetDialogUtils.openBottomSheet(
                FullscreenSourceUI(bottomSheet: true),
                closeBtnShow: false,
                backgroundColor: playerState.isFullscreen.value
                    ? PlayerCommons.playerUIBackgroundColor
                    : Colors.white,
              );
            } else {
              onlyShowUIByKeyList([PlayerUIKeyEnum.sourceUI.name]);
            }
          },
          child: Text("资源列表"),
        ),
      InkWell(
        onTap: () {
          hideCanControlUI();
          BottomSheetDialogUtils.closeBottomSheet();
          if (Get.size.width < Get.size.height) {
            BottomSheetDialogUtils.openBottomSheet(
              FullscreenChapterListUI(bottomSheet: true),
              closeBtnShow: false,
              backgroundColor: playerState.isFullscreen.value
                  ? PlayerCommons.playerUIBackgroundColor
                  : Colors.white,
            );
          } else {
            onlyShowUIByKeyList([PlayerUIKeyEnum.chapterListUI.name]);
          }
        },
        child: Text("章节列表"),
      ),
    ];
    uiState.settingsUIMap["subtitleList"] = [
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("字幕轨");
        },
        child: Text("字幕轨"),
      ),
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("字幕样式");
        },
        child: Text("字幕样式"),
      ),
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("字幕时间");
        },
        child: Text("字幕时间"),
      ),
    ];

    uiState.settingsUIMap["danmakuList"] = [
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("弹幕设置");
          hideUIByKeyList([PlayerUIKeyEnum.settingUI.name]);
          BottomSheetDialogUtils.closeBottomSheet();
          if (Get.size.width < Get.size.height) {
            BottomSheetDialogUtils.openBottomSheet(
              DefaultTextStyle(
                style: TextStyle(
                  color: playerState.isFullscreen.value
                      ? Colors.white
                      : Colors.black,
                ),
                child: Padding(
                  padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
                  child: DanmakuSettingUI(bottomSheet: true),
                ),
              ),
              closeBtnShow: !playerState.isFullscreen.value,
              backgroundColor: playerState.isFullscreen.value
                  ? PlayerCommons.playerUIBackgroundColor
                  : Colors.white,
            );
          } else {
            onlyShowUIByKeyList([PlayerUIKeyEnum.danmakuSettingUI.name]);
          }
        },
        child: Text("弹幕设置"),
      ),
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("弹幕轨");
        },
        child: Text("弹幕轨"),
      ),
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("弹幕源");
        },
        child: Text("弹幕源"),
      ),
      InkWell(
        onTap: () {
          LoggerUtils.logger.d("弹幕时间");
        },
        child: Text("弹幕时间"),
      ),
    ];
    uiState.settingsUIMap["speedList"] = [
      InkWell(
        onTap: () {
          // Get.closeAllBottomSheets();
          BottomSheetDialogUtils.closeBottomSheet();
          if (playerState.isFullscreen.value) {
            onlyShowUIByKeyList([PlayerUIKeyEnum.speedSettingUI.name]);
          } else {
            BottomSheetDialogUtils.openBottomSheet(
              PlayerSpeedUI(bottomSheet: Get.size.width < Get.size.height),
            );
          }
        },
        child: Text("播放倍数"),
      ),
    ];
  }

  void _initBottomControlItemList() {
    fullscreenBottomUIItemList = [
      PlayerBottomUIItemModel(
        type: ControlType.play,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 1,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          color: WidgetStyleCommons.iconColor,
          onPressed: () => playOrPause(),
          icon: Obx(() {
            var isFinished = playerState.isFinished.value;
            var isPlaying = playerState.isPlaying.value;
            return isFinished
                ? IconCommons.bottomReplayPlayIcon
                : (isPlaying
                      ? IconCommons.bottomPauseIcon
                      : IconCommons.bottomPlayIcon);
          }),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.next,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 2,
        child: Obx(
          () => resourcePlayState.haveNext
              ? IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: WidgetStyleCommons.iconColor,
                  onPressed: () => nextPlay(),
                  icon: IconCommons.nextPlayIcon,
                )
              : Container(),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.sendDanmaku,
        fixedWidth: 76,
        priority: 5,
        child: TextButton(onPressed: () {}, child: Text("发送弹幕")),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.danmaku,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 6,
        child: Obx(
          () => IconButton(
            onPressed: () => {
              danmakuState.isVisible.value = !danmakuState.isVisible.value,
            },
            icon: Image.asset(
              danmakuState.isVisible.value
                  ? IconCommons.danmakuOpenImgPath
                  : IconCommons.danmakuCloseImgPath,
              width: IconTheme.of(Get.context!).size ?? 24,
              height: IconTheme.of(Get.context!).size ?? 24,
            ),
          ),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.none,
        fixedWidth: 0,
        priority: 4,
        visible: true,
        child: Expanded(child: Container()),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.source,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 5,
        child: Obx(() {
          if (resourcePlayState.playSourceCount <= 1 &&
              resourcePlayState.sourceGroupCount <= 1) {
            return Container();
          }
          return IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            color: WidgetStyleCommons.iconColor,
            onPressed: () => {
              onlyShowUIByKeyList([PlayerUIKeyEnum.sourceUI.name]),
            },
            icon: Icon(Icons.source_rounded),
          );
        }),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.chapter,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 4,
        child: Obx(
          () => resourcePlayState.activatedChapterList.length > 1
              ? IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: WidgetStyleCommons.iconColor,
                  onPressed: () => {
                    onlyShowUIByKeyList([PlayerUIKeyEnum.chapterListUI.name]),
                  },
                  icon: Icon(Icons.list),
                )
              : Container(),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.speed,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 3,
        child: TextButton(
          onPressed: () =>
              onlyShowUIByKeyList([PlayerUIKeyEnum.speedSettingUI.name]),
          child: Obx(
            () => Text(
              "${playerState.playSpeed.value}x",
              style: TextStyle(color: PlayerCommons.textColor),
            ),
          ),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.exitOrEntryFullscreen,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 1,
        child: Obx(
          () => playerState.isFullscreen.value && !onlyFullscreen
              ? IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: WidgetStyleCommons.iconColor,
                  onPressed: () {
                    fullscreenUtils.toggleFullscreen();
                  },
                  icon: PlayerCommons.exitFullscreenIcon,
                )
              : Container(),
        ),
      ),
    ];
  }

  _initEver() {
    ever(player, (player) {
      player?.onInitPlayer();
    });

    ever(playerState.isInitialized, (value) {
      if (value && !uiState.uiLocked.value) {
        cancelAndRestartTimer();
        onlyShowUIByKeyList(uiState.touchBackgroundShowUIKeyList);
      }
      if (!value) {
        playerState.isPlaying.value = false;
        playerState.isBuffering.value = false;
      }
    });

    ever(playerState.isFinished, (value) {
      if (value) {
        playerState.isPlaying.value = false;
        playerState.isBuffering.value = false;
        if (resourcePlayState.haveNext) {
          nextPlay();
        }
      }
    });

    ever(resourcePlayState.resourcePlayingState, (val) async {
      danmakuState.danmakuFilePath.value = "";
      myDanmakuController.restDanmaku();

      // 视频切换前记录上一个视频的历史
      _recordPlayHistory();
      // 停止当前定时器
      _stopHistoryRecordTimer();
      // 清空上一个视频播放起始位置
      startPlayDuration = Duration.zero;
      // 从缓存中读取新视频开始播放位置
      int historyPosition = 0;
      if (resourcePlayState.videoModel.value == null) {
        if (resourcePlayState.activatedChapter != null &&
            resourcePlayState.activatedChapter!.playUrl!.isNotEmpty) {
          var playHistory = GStorage.histories.get(
            resourcePlayState.activatedChapter!.playUrl!,
          );
          if (playHistory != null) {
            var episodeInfo =
                playHistory.episodeInfo[playHistory.lastPlayEpisode];

            historyPosition = episodeInfo?.positionInMilli ?? 0;
          }
        }
      } else {
        var playHistory = GStorage.histories.get(
          "${resourcePlayState.playingApi?.api?.apiBaseModel.enName ?? ""}_${resourcePlayState.videoModel.value!.id}",
        );
        if (playHistory != null) {
          var episodeInfo =
              resourcePlayState.resourcePlayingState.value.chapterIndex - 1 <
                  playHistory.episodeInfo.length
              ? playHistory.episodeInfo[resourcePlayState
                        .resourcePlayingState
                        .value
                        .chapterIndex -
                    1]
              : null;
          historyPosition = episodeInfo?.positionInMilli ?? 0;
        }
      }
      resourcePlayState.activatedChapter?.historyDuration = Duration(
        milliseconds: historyPosition,
      );
      resourcePlayState.activatedChapter?.start = Duration(
        milliseconds: historyPosition,
      );

      await changeVideoUrl(
        autoPlay: _initialized ? playerState.autoPlay : true,
      );
      playerState.isPlaying.value = false;
      danmakuState.danmakuFilePath.value =
          resourcePlayState.activatedChapter?.mediaFileModel?.danmakuPath ?? "";
    });

    ever(playerState.isPlaying, (value) {
      if (value) {
        // 开始播放时启动定时器
        _startHistoryRecordTimer();

        // 播放时保持屏幕唤醒
        WakelockPlus.enable();
        myDanmakuController.resumeDanmaku();
      } else {
        // 暂停时停止定时器并立即记录一次
        _stopHistoryRecordTimer();
        _recordPlayHistory();

        // 暂停时关闭保持屏幕唤醒
        WakelockPlus.disable();
        myDanmakuController.pauseDanmaku();
      }
    });

    ever(playerState.playSpeed, (value) {
      GStorage.setting.put(
        "${SettingBoxKey.cachePrev}-${SettingBoxKey.playSpeed}",
        value,
      );
    });

    resourcePlayState.initEver();

    everAll([
      uiState.settingUI.visible,
      uiState.speedSettingUI.visible,
      uiState.sourceUI.visible,
      uiState.chapterListUI.visible,
    ], (value) => interceptPop.value = value);

    ever(uiState.danmakuSettingUI.visible, (value) {
      danmakuState.uiShowAdjustTime.value = danmakuState.adjustTime.value;
    });

    myDanmakuController.initEver();
  }

  @override
  void onClose() {
    // 应用退出前记录一次播放历史
    _recordPlayHistory();
    // 停止定时器
    _stopHistoryRecordTimer();

    hideTimer?.cancel();
    _progressTimer?.cancel();
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    player.value?.onDisposePlayer();

    // 销毁所有动画控制器
    uiState.disposeAllAnimationControllers();
    super.onClose();
  }

  void _startHistoryRecordTimer() {
    _stopHistoryRecordTimer(); // 先停止已有的定时器
    _historyRecordTimer = Timer.periodic(
      Duration(seconds: HISTORY_RECORD_INTERVAL),
      (timer) {
        _recordPlayHistory();
      },
    );
  }

  void _stopHistoryRecordTimer() {
    _historyRecordTimer?.cancel();
    _historyRecordTimer = null;
  }

  // 记录播放历史
  void _recordPlayHistory() {
    // 检查是否满足最小播放时间要求
    if (playerState.positionDuration.value.inSeconds -
            startPlayDuration.inSeconds <
        MIN_PLAY_TIME_FOR_HISTORY) {
      return;
    }

    // 检查播放器是否已初始化且没有错误
    if (!playerState.isInitialized.value || playerState.errorMsg.isNotEmpty) {
      return;
    }

    // 记录播放历史到数据库或本地存储
    _savePlayHistoryToStorage();
  }

  // 保存播放历史到存储
  void _savePlayHistoryToStorage() {
    // 根据当前播放的视频信息和播放位置保存历史记录
    resourcePlayState.activatedChapter?.historyDuration =
        playerState.positionDuration.value;

    if (resourcePlayState.videoModel.value == null) {
      GStorage.histories.put(
        resourcePlayState.activatedChapter!.playUrl,
        PlayHistory(
          VideoResource(
            resourceUrl: resourcePlayState.activatedChapter!.playUrl ?? "",
            coverUrl: "",
          ),
          {
            0: EpisodeInfo(
              0,
              resourcePlayState.activatedChapter!.name,
              resourcePlayState.activatedChapter!.playUrl ?? "",
              "",
              resourcePlayState
                      .activatedChapter!
                      .mediaFileModel
                      ?.assetEntity
                      ?.duration ??
                  0,
              resourcePlayState
                      .activatedChapter!
                      .historyDuration
                      ?.inMilliseconds ??
                  0,
            ),
          },
          0,
          DateTime.now(),
        ),
      );
    } else {
      Map<int, EpisodeInfo> episodeInfo = {};
      for (var item in resourcePlayState.activatedChapterList) {
        episodeInfo[item.index] = EpisodeInfo(
          item.index,
          item.name,
          item.playUrl ?? "",
          resourcePlayState.videoModel.value?.coverUrl ?? "",
          item.mediaFileModel?.assetEntity?.duration ?? 0,
          item.historyDuration?.inMilliseconds ?? 0,
        );
      }

      PlayHistory playHistory = PlayHistory(
        VideoResource(
          apiKey: resourcePlayState.playingApi?.api?.apiBaseModel.enName ?? "",
          spiGroupEnName: resourcePlayState.playingSourceGroup?.enName ?? "",
          resourceId: resourcePlayState.videoModel.value?.id ?? "",
          resourceEnName: resourcePlayState.videoModel.value?.enName ?? "",
          resourceName: resourcePlayState.videoModel.value?.name ?? "",
          resourceUrl: "",
          coverUrl: resourcePlayState.videoModel.value?.coverUrl ?? "",
        ),
        episodeInfo,
        resourcePlayState.resourcePlayingState.value.chapterIndex,
        DateTime.now(),
      );

      GStorage.histories.put(
        "${resourcePlayState.playingApi?.api?.apiBaseModel.enName ?? ""}_${resourcePlayState.videoModel.value!.id}",
        playHistory,
      );
    }
  }

  // 清除定时器
  void cancelHideTimer() {
    hideTimer?.cancel();
  }

  // 开始计时UI显示时间
  void startHideTimer() {
    hideTimer = Timer(PlayerCommons.uiShowDuration, () {
      hideUIByKeyList(uiState.touchBackgroundShowUIKeyList);
    });
  }

  // 重新计算显示/隐藏UI计时器
  void cancelAndRestartTimer() {
    cancelHideTimer();
    startHideTimer();
  }

  void resetPlayerState() {
    playerState.aspectRatio(null);
    playerState.videoAspectRatio = null;
    playerState.errorMsg(null);
    playerState.isInitialized(false);
    playerState.isPlaying(false);
    playerState.isBuffering(false);
    playerState.isSeeking(false);
    playerState.isFinished(false);

    playerState.duration(Duration.zero);
    playerState.positionDuration(Duration.zero);
    playerState.bufferedDuration(Duration.zero);
    playerState.beforeSeekToIsPlaying = false;
    playerState.isDragging(false);
    playerState.dragProgressPositionDuration = Duration.zero;
    playerState.draggingSecond(0);
    playerState.draggingSurplusSecond = 0.0;

    playerState.verticalDragSurplus = 0.0;
    playerState.isVolumeDragging(false);
    playerState.isBrightnessDragging(false);
  }

  Future<void> changeVideoUrl({bool autoPlay = true}) async {
    await stop();
    resetPlayerState();
    player.value?.changeVideoUrl(autoPlay: autoPlay);
  }

  // 视频播放
  Future<void> play() async {
    if (!uiState.uiLocked.value) {
      cancelAndRestartTimer();
      onlyShowUIByKeyList(uiState.touchBackgroundShowUIKeyList);
    }
    return player.value?.play();
  }

  // 视频暂停
  Future<void> pause() async {
    return player.value?.pause();
  }

  Future<void> stop() async {
    myDanmakuController.stopDanmaku();
    await player.value?.stop();
    playerState.isPlaying.value = false;
  }

  // 暂停或播放
  Future<void> playOrPause() async {
    if (player.value == null) {
      return;
    }
    if (player.value!.finished) {
      // await seekTo(Duration.zero);
    }
    if (player.value!.playing) {
      return pause();
    } else {
      return play();
    }
  }

  Future<void> seekTo(Duration position) async {
    playerState.positionDuration(position);
    playerState.isSeeking(true);
    playerState.positionDuration(position); // 立即更新UI位置
    await player.value?.seekTo(position);
    playerState.beforeSeekToIsPlaying = false;
    playerState.isSeeking(false);
  }

  Future<void> beforeSeekTo() async {}

  Future<void> afterSeekTo() async {}

  /// ui控制部分

  /// 点击背景
  void toggleBackground() {
    LoggerUtils.logger.d("点击背景");
    if (haveUIShow()) {
      hideTimer?.cancel();
      LoggerUtils.logger.d("有显示");
      hideUIByKeyList(
        uiState.overlayUIMap.keys
            .where((e) => !uiState.notTouchCtrlKeyList.contains(e))
            .toList(),
      );
    } else {
      cancelHideTimer();
      onlyShowUIByKeyList(
        uiState.uiLocked.value
            ? [PlayerUIKeyEnum.lockCtrUI.name]
            : uiState.touchBackgroundShowUIKeyList,
      );
      startHideTimer();
    }
  }

  // 隐藏可操作UI
  void hideCanControlUI() {
    hideUIByKeyList([
      ...uiState.touchBackgroundShowUIKeyList,
      ...uiState.interceptRouteUIKeyList,
    ]);
  }

  /// 是否有UI显示（除了特殊的UI）
  bool haveUIShow({bool ignoreLimit = false}) {
    bool flag = false;
    for (var element in uiState.overlayUIMap.values) {
      if (!ignoreLimit && uiState.notTouchCtrlKeyList.contains(element.key)) {
        continue;
      }
      if (element.key == uiState.leftBottomHitUI.key) {
        LoggerUtils.logger.d(element.key);
      }
      if (element.visible.value) {
        flag = true;
        break;
      }
    }
    return flag;
  }

  // 根据Key值隐藏ui
  void hideUIByKeyList(List<String> keyList) {
    LoggerUtils.logger.d("隐藏ui：$keyList");
    if (keyList.isEmpty) {
      return;
    }
    for (MapEntry<String, PlayerOverlayUIModel> entry
        in uiState.overlayUIMap.entries) {
      if (!keyList.contains(entry.key)) {
        continue;
      }
      PlayerOverlayUIModel element = entry.value;
      element.visible(false);
      if (element.ui.value == null) {
        continue;
      }
      if (element.useAnimationController) {
        element.animateController?.reverse();
      } else {
        element.ui(Container(key: UniqueKey()));
      }
    }

    bool haveToggleBackgroundUI = false;
    for (String key in keyList) {
      if (uiState.touchBackgroundShowUIKeyList.contains(key)) {
        haveToggleBackgroundUI = true;
        break;
      }
    }
    if (haveToggleBackgroundUI) {
      hideTimer?.cancel();
    }
  }

  // 只显示指定key值显示UI
  void onlyShowUIByKeyList(List<String> keyList, {bool ignoreLimit = false}) {
    List<String> hideList = [];
    for (MapEntry<String, PlayerOverlayUIModel> entry
        in uiState.overlayUIMap.entries) {
      if (!ignoreLimit && uiState.notTouchCtrlKeyList.contains(entry.key)) {
        continue;
      }
      if (!keyList.contains(entry.key)) {
        hideList.add(entry.key);
        continue;
      }
      PlayerOverlayUIModel element = entry.value;
      element.visible(true);
      element.ui(element.child);
      if (element.useAnimationController) {
        element.animateController?.forward();
      }
    }
    if (hideList.isNotEmpty) {
      hideUIByKeyList(hideList);
    }
  }

  void showUIByKeyList(List<String> keyList) {
    for (var key in keyList) {
      PlayerOverlayUIModel? element = uiState.overlayUIMap[key];
      if (element == null) {
        continue;
      }
      element.visible(true);
      element.ui(element.child);
      if (element.useAnimationController) {
        element.animateController?.forward();
      }
    }
  }

  void _createUIAnimate(PlayerOverlayUIModel uiOverlay) {
    if (uiState.playerUIState == null) {
      return;
    }
    // 当前UI是否需要动画控制器（有效ui直接使用属性动画）
    if (uiOverlay.useAnimationController) {
      // 先销毁已存在的控制器（如果有的话）
      if (uiOverlay.animateController != null) {
        try {
          uiOverlay.animateController?.dispose();
        } catch (_) {}
      }
      uiOverlay.animateController = AnimationController(
        duration:
            uiOverlay.animationDuration ??
            PlayerCommons.playerUIAnimationDuration,
        vsync: uiState.playerUIState,
      );

      uiOverlay.animation?.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          // 改成null不会触发，因此用Container()来代替
          uiOverlay.ui(Container(key: UniqueKey()));
        }
      });
    }
  }

  // 更新动画控制
  void updateAnimateController(playerUIState) {
    uiState.playerUIState = playerUIState;
    // 遍历需要显示的UI并生成对应的动画控制
    uiState.overlayUIMap.forEach((key, uiOverlay) {
      _createUIAnimate(uiOverlay);
    });
  }

  // 新增显示的UI
  void addUI(String key, PlayerOverlayUIModel uiOverlay) {
    if (uiState.playerUIState == null) {
      LoggerUtils.logger.e("还未初始化，无法添加");
      return;
    }
    _createUIAnimate(uiOverlay);
    uiState.overlayUIMap.addAll({key: uiOverlay});
  }

  Timer? _progressTimer;
  // 开始拖动播放进度条
  void playProgressOnHorizontalDragStart() {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.isNotEmpty ||
        playerState.isFinished.value) {
      return;
    }
    _progressTimer?.cancel();
    // 标记拖动状态
    playerState.isDragging(true);
    // 初始化拖动值
    playerState.draggingSecond(0);
    // 清除前一次拖动剩余
    playerState.draggingSurplusSecond = 0.0;
    // 记录开始拖动时的时间
    playerState.dragProgressPositionDuration =
        playerState.positionDuration.value;
    //显示拖动进度UI
    onlyShowUIByKeyList([
      PlayerUIKeyEnum.centerProgressUI.name,
    ], ignoreLimit: true);
  }

  // 拖动播放进度条中
  void playProgressOnHorizontalDragUpdate(BuildContext context, Offset delta) {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.isNotEmpty ||
        playerState.isFinished.value) {
      hideUIByKeyList([PlayerUIKeyEnum.centerProgressUI.name]);
      return;
    }
    _progressTimer?.cancel();
    double width = Get.size.width;
    // 获取拖动了多少秒
    double dragSecond =
        (delta.dx / width) * 100 + playerState.draggingSurplusSecond;
    // 拖动秒数向下取整
    int dragValue = dragSecond.floor();
    // 记录本次拖动取整后剩余
    playerState.draggingSurplusSecond = dragSecond - dragValue;
    // 更新拖动值
    playerState.draggingSecond(playerState.draggingSecond.value + dragValue);
    //显示拖动进度UI
    onlyShowUIByKeyList([
      PlayerUIKeyEnum.centerProgressUI.name,
    ], ignoreLimit: true);
  }

  // 拖动播放进度结束
  void playProgressOnHorizontalDragEnd() {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.isNotEmpty ||
        playerState.isFinished.value) {
      hideUIByKeyList([PlayerUIKeyEnum.centerProgressUI.name]);
      return;
    }
    // 清除拖动标记
    playerState.isDragging(false);
    // 清除前一次拖动剩余值
    playerState.draggingSurplusSecond = 0.0;
    // 更新本次拖动值
    var second =
        playerState.dragProgressPositionDuration.inSeconds +
        playerState.draggingSecond.value;
    seekTo(Duration(seconds: second.abs() > 0 ? second : 0));
    // 定时隐藏拖动进度ui
    _progressTimer = Timer.periodic(
      PlayerCommons.volumeOrBrightnessUIShowDuration,
      (timer) {
        _progressTimer?.cancel();
        playerState.draggingSecond(0);
        playerState.dragProgressPositionDuration =
            playerState.positionDuration.value;
        hideUIByKeyList([PlayerUIKeyEnum.centerProgressUI.name]);
      },
    );
  }

  Timer? _volumeTimer;
  Timer? _brightnessTimer;
  // 垂直滑动开始
  void volumeOrBrightnessOnVerticalDragStart(DragStartDetails details) {
    if (isWeb) {
      return;
    }
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    playerState.isBrightnessDragging(false);
    playerState.isVolumeDragging(false);
    double width = Get.size.width;
    String showUIKey;
    if (details.globalPosition.dx > (width / 2)) {
      FlutterVolumeController.updateShowSystemUI(false);
      FlutterVolumeController.getVolume().then(
        (value) => playerState.volume(((value ?? 0) * 100).floor()),
      );
      playerState.isVolumeDragging(true);
      showUIKey = PlayerUIKeyEnum.centerVolumeUI.name;
      hideUIByKeyList([PlayerUIKeyEnum.centerBrightnessUI.name]);
    } else {
      // 获取当前亮度
      ScreenBrightness.instance.application.then(
        (value) => playerState.brightness((value * 100).floor()),
      );
      playerState.isBrightnessDragging(true);
      showUIKey = PlayerUIKeyEnum.centerBrightnessUI.name;
      hideUIByKeyList([PlayerUIKeyEnum.centerVolumeUI.name]);
    }
    playerState.verticalDragSurplus = 0.0;
    onlyShowUIByKeyList([showUIKey], ignoreLimit: true);
  }

  // 垂直滑动中
  void volumeOrBrightnessOnVerticalDragUpdate(
    BuildContext context,
    DragUpdateDetails details,
  ) {
    if (isWeb) {
      return;
    }
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    double height = Get.size.height;
    // 使用百分率
    // 当前拖动值
    double currentDragVal = (details.delta.dy / height) * 100;
    double totalDragValue = currentDragVal + playerState.verticalDragSurplus;
    int dragValue = totalDragValue.floor();
    playerState.verticalDragSurplus = totalDragValue - dragValue;
    String showUIKey = "";
    if (playerState.isVolumeDragging.value) {
      // 设置音量
      playerState.volume((playerState.volume.value - dragValue).clamp(0, 100));
      FlutterVolumeController.updateShowSystemUI(false);
      FlutterVolumeController.setVolume(playerState.volume / 100.0);
      showUIKey = PlayerUIKeyEnum.centerVolumeUI.name;
      hideUIByKeyList([PlayerUIKeyEnum.centerBrightnessUI.name]);
    } else if (playerState.isBrightnessDragging.value) {
      // 设置亮度
      playerState.brightness(
        (playerState.brightness.value - dragValue).clamp(0, 100),
      );
      ScreenBrightness.instance.setApplicationScreenBrightness(
        playerState.brightness / 100.0,
      );
      showUIKey = PlayerUIKeyEnum.centerBrightnessUI.name;
      hideUIByKeyList([PlayerUIKeyEnum.centerVolumeUI.name]);
    }
    onlyShowUIByKeyList([showUIKey], ignoreLimit: true);
  }

  // 垂直滑动结束
  void volumeOrBrightnessOnVerticalDragEnd() {
    if (isWeb) {
      return;
    }
    if (playerState.isBrightnessDragging.value) {
      _brightnessTimer = Timer(
        PlayerCommons.volumeOrBrightnessUIShowDuration,
        () {
          _brightnessTimer?.cancel();
          hideUIByKeyList([PlayerUIKeyEnum.centerBrightnessUI.name]);
        },
      );
    }
    if (playerState.isVolumeDragging.value) {
      _volumeTimer = Timer(PlayerCommons.volumeOrBrightnessUIShowDuration, () {
        _volumeTimer?.cancel();
        hideUIByKeyList([PlayerUIKeyEnum.centerVolumeUI.name]);
      });
    }
    playerState.isBrightnessDragging(false);
    playerState.isVolumeDragging(false);
    playerState.verticalDragSurplus = 0.0;
  }

  void nextPlay() {
    resourcePlayState.chapterActivatedIndex.value =
        resourcePlayState.chapterActivatedIndex.value + 1;
  }

  void fullScreenWidthChange(double maxWidth) {
    if (maxWidth > PlayerCommons.chapterUIDefaultWidth) {
      if (!uiState.chapterListUI.visible.value) {
        hideUIByKeyList([PlayerUIKeyEnum.chapterListUI.name]);
      }
    }
  }
}
