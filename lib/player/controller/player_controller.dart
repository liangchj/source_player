import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/iplayer.dart';
import 'package:source_player/player/state/player_ui_state.dart';
import 'package:source_player/utils/logger_utils.dart';

import '../commons/player_commons.dart';
import '../enums/player_ui_key_enum.dart';
import '../media_kit_player.dart';
import '../models/player_overlay_ui_model.dart';
import '../player_view.dart';
import '../state/player_state.dart';
import '../utils/fullscreen_utils.dart';

class PlayerController extends GetxController {
  var player = Rx<IPlayer?>(null);
  PlayerController();

  late PlayerState playerState;

  late PlayerUIState uiState;

  bool isWeb = kIsWeb;

  late FullscreenUtils fullscreenUtils;

  // 标记是否只有全屏页面
  bool onlyFullscreen = false;



  @override
  void onInit() {
    playerState = PlayerState();
    uiState = PlayerUIState();
    fullscreenUtils = FullscreenUtils(this);

    _initEver();

    super.onInit();
  }

  _initEver() {
    ever(player, (player) {
      player?.onInitPlayer();
    });
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

  Future<void> seekTo(Duration position) {
    return player.value!.seekTo(position);
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
}
