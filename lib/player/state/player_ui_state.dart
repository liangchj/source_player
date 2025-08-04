import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enums/player_ui_key_enum.dart';
import '../models/player_overlay_ui_model.dart';
import '../ui/center_play_progress_ui.dart';
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
      PlayerUIKeyEnum.centerVolumeAndBrightnessUI.name:
          centerVolumeAndBrightnessUI,
    });
  }
  Map<String, PlayerOverlayUIModel> overlayUIMap = {};

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
    PlayerUIKeyEnum.centerVolumeAndBrightnessUI.name,
    PlayerUIKeyEnum.centerErrorUI.name,
  ];

  // 拦截路由UI列表
  List<String> interceptRouteUIKeyList = [
    PlayerUIKeyEnum.settingUI.name,
    PlayerUIKeyEnum.speedSettingUI.name,
    PlayerUIKeyEnum.chapterListUI.name,
  ];

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
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUISlideTransition(uiModel),
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

  var centerVolumeAndBrightnessUI = PlayerOverlayUIModel(
    key: PlayerUIKeyEnum.centerVolumeAndBrightnessUI.name,
    useAnimationController: true,
    tween: Tween<Opacity>(
      begin: Opacity(opacity: 0.0),
      end: Opacity(opacity: 1.0),
    ),
    animationDuration: Duration.zero,
    widgetCallback: (uiModel) =>
        PlayerUITransition.playerUIOpacityAnimation(uiModel),
  );
}
