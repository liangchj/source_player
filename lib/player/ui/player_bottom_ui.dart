import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../commons/player_commons.dart';

class PlayerBottomUI extends StatefulWidget {
  const PlayerBottomUI({super.key});

  @override
  State<PlayerBottomUI> createState() => _PlayerBottomUIState();
}

class _PlayerBottomUIState extends State<PlayerBottomUI> {
  PlayerController get controller => Get.find<PlayerController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      // 背景渐变效果
      decoration: BoxDecoration(gradient: PlayerCommons.bottomUILinearGradient),
      child: _buildVerticalScreenBottomUI(),
    );
  }

  // 竖屏底部UI
  Widget _buildVerticalScreenBottomUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 播放/暂停按钮
        _buildPlayPause(),
        // 下一个视频按钮

        // 播放时长
        // _buildPlayPositionDuration(),
        // 进度条

        // 总时长
        // _buildTotalDuration(),

        // 全屏按钮
        IconButton(onPressed: () {
          controller.fullscreenUtils.toggleFullScreen(context: context);
          /*if (controller.playerState.fullScreen.value) {
            controller.exitFullScreen();
          } else {
            controller.entryFullScreen(context);
          }*/
        }, icon: PlayerCommons.entryFullScreenIcon),
      ],
    );
  }

  // 播放、暂停按钮
  Widget _buildPlayPause() {
    return IconButton(
      onPressed: () => controller.playOrPause(),
      icon: Obx(() {
        var isFinished = controller.playerState.finished.value;
        var isPlaying = controller.playerState.playing.value;
        return Icon(
          isFinished
              ? Icons.play_arrow
              : (isPlaying ? Icons.pause : Icons.play_arrow),
        );
      }),
    );
  }
}
