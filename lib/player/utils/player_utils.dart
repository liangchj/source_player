import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
import '../controller/player_controller.dart';
import '../iplayer.dart';
import '../models/resource_play_state_model.dart';
import '../player_view.dart';

class PlayerUtils {
  // 本地视频播放器
  static void openLocalVideo({
    IPlayer? player,
    VideoModel? videoModel,
    List<ResourceChapterModel>? chapterList,
    ResourcePlayStateModel? playStateModel,
    Function(PlayerController)? playerControllerCallback,
  }) {
    Get.delete<PlayerController>();
    Get.to(
      () => Scaffold(
        body: PlayerView(
          player: player,
          onCreatePlayerController: (playerController) {
            playerController.onlyFullscreen = true;
            playerController.fullscreenUtils.enterFullscreen();

            playerController.playerState.autoPlay = true;
            playerController.resourcePlayState.playStateModel = playStateModel;

            if (videoModel != null) {
              playerController.resourcePlayState.videoModel.value = videoModel;
            }
            if (chapterList != null) {
              playerController.resourcePlayState.chapterList.value =
                  chapterList;
            }

            playerControllerCallback?.call(playerController);
          },
        ),
      ),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );
  }
}
