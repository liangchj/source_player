import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:source_player/player/iplayer.dart';

import '../media_kit_player.dart';
import '../player_view.dart';
import '../state/player_state.dart';
import '../utils/fullscreen_utils.dart';

class PlayerController extends GetxController {
  var player = Rx<IPlayer?>(null);
  PlayerController();

  late PlayerState playerState;

  bool isWeb = kIsWeb;


  late FullscreenUtils fullscreenUtils;

  // 新增：用于本地视频的特殊标记
  bool isLocalVideo = false;

  @override
  void onInit() {
    playerState = PlayerState();
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


  // 本地播放
  void openLocalVideo({IPlayer? player}) {
    isLocalVideo = true;
    if (player == null) {
      MediaKit.ensureInitialized();
    }
    playerState.autoPlay = true;
    this.player(player ?? MediaKitPlayer());
    playerState.fullScreen(true);
    fullscreenUtils.enterFullScreen(Get.context!);

    /*Navigator.of(Get.context!, rootNavigator: true).push(
      PageRouteBuilder(pageBuilder:  (_, __, ___) => Material(child: FullScreenPlayerPage(),),),
    );*/
    /*controller.playerController.initialize().then((_) {
      // 直接进入全屏模式
      controller.isFullScreen.value = true;
      controller._enterFullScreen(Get.context!);
    });*/
  }
}
