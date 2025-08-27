import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/ui/danmaku_setting_ui.dart';
import 'package:source_player/player/ui/player_setting_ui.dart';

import '../enums/player_ui_key_enum.dart';
import '../models/player_overlay_ui_model.dart';
import '../ui/brightness_volume_ui.dart';
import '../ui/center_play_progress_ui.dart';
import '../ui/fullscreen_chapter_list_ui.dart';
import '../ui/player_bottom_ui.dart';
import '../ui/player_lock_ui.dart';
import '../ui/player_screenshot_ui.dart';
import '../ui/player_speed_ui.dart';
import '../ui/player_top_ui.dart';

class PlayerUIState {
  // 锁住ui
  var uiLocked = false.obs;
  dynamic playerUIState;
  PlayerUIState() {
    overlayUIMap.addAll({
      PlayerUIKeyEnum.topUI.name: topUI,
      PlayerUIKeyEnum.bottomUI.name: bottomUI,
      PlayerUIKeyEnum.speedSettingUI.name: speedSettingUI,
      PlayerUIKeyEnum.lockCtrUI.name: lockCtrUI,
      PlayerUIKeyEnum.screenshotCtrUI.name: screenshotCtrUI,
      PlayerUIKeyEnum.centerProgressUI.name: centerProgressUI,
      PlayerUIKeyEnum.centerVolumeUI.name: centerVolumeUI,
      PlayerUIKeyEnum.centerBrightnessUI.name: centerBrightnessUI,
      PlayerUIKeyEnum.settingUI.name: settingUI,
      PlayerUIKeyEnum.chapterListUI.name: chapterListUI,
      PlayerUIKeyEnum.leftBottomHitUI.name: leftBottomHitUI,
      PlayerUIKeyEnum.restartUI.name: restartUI,
      PlayerUIKeyEnum.danmakuSettingUI.name: danmakuSettingUI,
    });
  }
  Map<String, PlayerOverlayUIModel> overlayUIMap = {};

  // 新增方法：销毁所有动画控制器
  void disposeAllAnimationControllers() {
    overlayUIMap.forEach((key, uiModel) {
      if (uiModel.animateController != null) {
        try {
          uiModel.animateController?.dispose();
        } catch (_) {}
        uiModel.animateController = null;
      }
    });
  }

  // 点击背景时需要显示的UI列表（一般是顶部、底部、左边锁键和右边截图按钮，在报错情况下只显示顶部）
  List<String> touchBackgroundShowUIKeyList = [
    PlayerUIKeyEnum.topUI.name,
    PlayerUIKeyEnum.bottomUI.name,
    PlayerUIKeyEnum.lockCtrUI.name,
    PlayerUIKeyEnum.screenshotCtrUI.name,
  ];

  // 自己控制的ui，不受其他ui影响
  List<String> notTouchCtrlKeyList = [
    PlayerUIKeyEnum.centerLoadingUI.name,
    PlayerUIKeyEnum.centerProgressUI.name,
    PlayerUIKeyEnum.centerVolumeUI.name,
    PlayerUIKeyEnum.centerBrightnessUI.name,
    PlayerUIKeyEnum.centerErrorUI.name,
    PlayerUIKeyEnum.leftBottomHitUI.name,
    PlayerUIKeyEnum.restartUI.name,
  ];

  // 拦截路由UI列表
  List<String> interceptRouteUIKeyList = [
    PlayerUIKeyEnum.settingUI.name,
    PlayerUIKeyEnum.speedSettingUI.name,
    PlayerUIKeyEnum.chapterListUI.name,
  ];

  final RxDouble bottomUIHeight = 0.0.obs;
  double? bottomUIOffsetY = 0.0;

  var topUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.topUI.name,
    child: const PlayerTopUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(0.0, -1),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );
  var bottomUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.bottomUI.name,
    child: PlayerBottomUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(0.0, 1),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) {
      // print("底部uiOffset:${uiModel.tween.}")
      return PlayerUITransition.playerUISlideTransition(uiModel);
    },
  );

  var speedSettingUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.speedSettingUI.name,
    child: const PlayerSpeedUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  var lockCtrUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.lockCtrUI.name,
    child: const PlayerLockUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  var screenshotCtrUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.screenshotCtrUI.name,
    child: const PlayerScreenshotUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  var centerProgressUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.centerProgressUI.name,
    child: const CenterPlayProgressUI(),
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );

  var centerVolumeUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.centerVolumeUI.name,
    child: const BrightnessVolumeUI(
      brightnessVolumeType: BrightnessVolumeType.volume,
    ),
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );

  var centerBrightnessUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.centerBrightnessUI.name,
    child: const BrightnessVolumeUI(
      brightnessVolumeType: BrightnessVolumeType.brightness,
    ),
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );

  var settingUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.settingUI.name,
    child: const PlayerSettingUI(),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  var chapterListUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.chapterListUI.name,
    child: const FullscreenChapterListUI(bottomSheet: false),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  var restartUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.restartUI.name,
    child: null,
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );
  var leftBottomHitUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.leftBottomHitUI.name,
    child: null,
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );

  var danmakuSettingUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.danmakuSettingUI.name,
    child: const DanmakuSettingUI(bottomSheet: false),
    useAnimationController: true,
    tween: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ),
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
  );

  final Rx<String?> bottomLeftMsg = Rx(null);

  Map<String, List<Widget>> settingsUIMap = {};
}
