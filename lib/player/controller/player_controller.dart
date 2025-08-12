import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:screen_brightness/screen_brightness.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/iplayer.dart';
import 'package:source_player/player/state/player_ui_state.dart';
import 'package:source_player/utils/logger_utils.dart';

import '../../commons/icon_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../commons/player_commons.dart';
import '../enums/player_ui_key_enum.dart';
import '../media_kit_player.dart';
import '../models/buttom_ui_control_item_model.dart';
import '../models/player_overlay_ui_model.dart';
import '../player_view.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../ui/brightness_volume_ui.dart';
import '../utils/fullscreen_utils.dart';

class PlayerController extends GetxController {
  var player = Rx<IPlayer?>(null);

  NetResourceDetailController? netResourceDetailController;

  late ResourceState resourceState;

  PlayerController();

  late PlayerState playerState;

  late PlayerUIState uiState;

  bool isWeb = kIsWeb;

  late FullscreenUtils fullscreenUtils;

  // 标记是否只有全屏页面
  bool onlyFullscreen = false;

  List<PlayerBottomUIItemModel> fullscreenBottomUIItemList = [];

  @override
  void onInit() {
    resourceState = ResourceState();
    playerState = PlayerState();
    uiState = PlayerUIState();
    fullscreenUtils = FullscreenUtils(this);

    _initEver();

    _initBottomControlItemList();
    super.onInit();
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
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          onPressed: () => {},
          icon: IconCommons.nextPlayIcon,
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.sendDanmaku,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 5,
        child: TextButton(onPressed: () {}, child: Text("发送弹幕")),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.danmaku,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 6,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          onPressed: () => {},
          icon: IconCommons.danmakuBottomOpen,
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.danmakuSetting,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 7,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          onPressed: () => {},
          icon: IconCommons.danmakuSetting,
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.chapter,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 4,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          onPressed: () => {},
          icon: Icon(Icons.list),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.speed,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 3,
        child: TextButton(
          onPressed: () =>
              showUIByKeyList([PlayerUIKeyEnum.speedSettingUI.name]),
          child: Text(
            "${playerState.playSpeed.value}x",
            style: TextStyle(color: PlayerCommons.textColor),
          ),
        ),
      ),
      PlayerBottomUIItemModel(
        type: ControlType.exitOrEntryFullscreen,
        fixedWidth: PlayerCommons.bottomBtnSize,
        priority: 1,
        child: Obx(
          () => playerState.isFullscreen.value
              ? IconButton(
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
    resourceState.initEver();
  }

  @override
  void onClose() {
    player.value?.onDisposePlayer();
    super.onClose();
  }

  // 视频播放
  Future<void> play() {
    return player.value!.play();
  }

  // 视频暂停
  Future<void> pause() {
    return player.value!.pause();
  }

  // 暂停或播放
  Future<void> playOrPause() async {
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
    await player.value!.seekTo(position);
    playerState.beforeSeekToIsPlaying = false;
    playerState.isSeeking(false);
  }

  // 本地播放
  void openLocalVideo({IPlayer? player}) {
    onlyFullscreen = true;
    if (player == null) {
      MediaKit.ensureInitialized();
    }
    playerState.autoPlay = false;
    // playerState.autoPlay = true;
    this.player(player ?? MediaKitPlayer());
    playerState.isFullscreen(true);
    fullscreenUtils.enterFullscreen(Get.context!);
  }

  /// ui控制部分

  /// 点击背景
  void toggleBackground() {
    LoggerUtils.logger.d("点击背景");
    if (haveUIShow()) {
      LoggerUtils.logger.d("有显示");
      hideUIByKeyList(
        uiState.overlayUIMap.keys
            .where((e) => !uiState.notTouchCtrlKeyList.contains(e))
            .toList(),
      );
    } else {
      showUIByKeyList(
        uiState.uiLocked.value
            ? [PlayerUIKeyEnum.lockCtrUI.name]
            : uiState.touchBackgroundShowUIKeyList,
      );
    }
  }

  /// 是否有UI显示（除了特殊的UI）
  bool haveUIShow({bool ignoreLimit = false}) {
    bool flag = false;
    for (var element in uiState.overlayUIMap.values) {
      if (!ignoreLimit && uiState.notTouchCtrlKeyList.contains(element.key)) {
        continue;
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
  }

  // 只显示指定key值显示UI
  void showUIByKeyList(List<String> keyList, {bool ignoreLimit = false}) {
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

  void _createUIAnimate(PlayerOverlayUIModel uiOverlay) {
    // 当前UI是否需要动画控制器（有效ui直接使用属性动画）
    if (uiOverlay.useAnimationController) {
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
    showUIByKeyList([PlayerUIKeyEnum.centerProgressUI.name], ignoreLimit: true);
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
    showUIByKeyList([showUIKey], ignoreLimit: true);
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
    showUIByKeyList([showUIKey], ignoreLimit: true);
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
          hideUIByKeyList([PlayerUIKeyEnum.centerBrightnessUI.name]);
        },
      );
    }
    if (playerState.isVolumeDragging.value) {
      _volumeTimer = Timer(PlayerCommons.volumeOrBrightnessUIShowDuration, () {
        hideUIByKeyList([PlayerUIKeyEnum.centerVolumeUI.name]);
      });
    }
    playerState.isBrightnessDragging(false);
    playerState.isVolumeDragging(false);
    playerState.verticalDragSurplus = 0.0;
    /*Future.delayed(PlayerCommons.volumeOrBrightnessUIShowDuration).then((value) {
    });*/
  }
}
