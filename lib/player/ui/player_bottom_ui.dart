import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../../commons/icon_commons.dart';
import '../../commons/widget_style_commons.dart';
import '../../utils/logger_utils.dart';
import '../commons/player_commons.dart';
import '../utils/time_format_utils.dart';

class PlayerBottomUI extends StatefulWidget {
  const PlayerBottomUI({super.key});

  @override
  State<PlayerBottomUI> createState() => _PlayerBottomUIState();
}

class _PlayerBottomUIState extends State<PlayerBottomUI> {
  PlayerController get controller => Get.find<PlayerController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        // 背景渐变效果
        decoration: BoxDecoration(
          gradient: PlayerCommons.bottomUILinearGradient,
        ),
        child: _buildBottomUI(),
      ),
    );
  }

  Widget _buildBottomUI() {
    return Obx(() {
      return controller.playerState.isFullscreen.value
          ? Obx(
              () => Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: WidgetStyleCommons.safeSpace,
                    ),
                    child: _buildProgressBar(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.fullscreenBottomUIItemList
                        .where((item) => item.visible.value)
                        .map((e) => e.child)
                        .toList(),
                  ),
                ],
              ),
            )
          : _buildVerticalScreenBottomUI();
    });
  }

  // 竖屏底部UI
  Widget _buildVerticalScreenBottomUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 播放/暂停按钮
        _buildPlayPause(),
        Obx(
          () => controller.resourceState.haveNext
              ? IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: WidgetStyleCommons.iconColor,
                  onPressed: () => controller.nextPlay(),
                  icon: IconCommons.nextPlayIcon,
                )
              : Container(),
        ),
        // 进度条
        Expanded(child: _buildProgressBar()),
        // 全屏下转为横屏/竖屏
        if (!controller.onlyFullscreen)
          // 全屏/退出全屏按钮
          IconButton(
            onPressed: () {
              controller.fullscreenUtils.toggleFullscreen(context: context);
            },
            icon: Obx(
              () => controller.playerState.isFullscreen.value
                  ? PlayerCommons.exitFullscreenIcon
                  : PlayerCommons.entryFullscreenIcon,
            ),
          ),
      ],
    );
  }

  // 播放、暂停按钮
  Widget _buildPlayPause() {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      color: WidgetStyleCommons.iconColor,
      onPressed: () => controller.playOrPause(),
      icon: Obx(() {
        var isFinished = controller.playerState.isFinished.value;
        var isPlaying = controller.playerState.isPlaying.value;
        return isFinished
            ? IconCommons.bottomReplayPlayIcon
            : (isPlaying
                  ? IconCommons.bottomPauseIcon
                  : IconCommons.bottomPlayIcon);
      }),
    );
  }

  /// 已播放时长
  Widget _buildPlayPositionDuration({EdgeInsetsGeometry? padding}) {
    return Obx(
      () => Text(
        TimeFormatUtils.durationToMinuteAndSecond(
          controller.playerState.positionDuration.value,
        ),
      ),
    );
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      child: Obx(
        () => Text(
          TimeFormatUtils.durationToMinuteAndSecond(
            controller.playerState.positionDuration.value,
          ),
        ),
      ),
    );
  }

  /// 总时长
  Widget _buildTotalDuration({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      child: Obx(
        () => Text(
          TimeFormatUtils.durationToMinuteAndSecond(
            controller.playerState.duration.value,
          ),
        ),
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar() {
    return Obx(() {
      if (!controller.uiState.bottomUI.visible.value) {
        return Container();
      }
      LoggerUtils.logger.d("播放进度：${controller.playerState.positionDuration}");
      return AbsorbPointer(
        absorbing: !controller.playerState.isInitialized.value,
        child: ProgressBar(
          timeLabelLocation: TimeLabelLocation.sides,
          timeLabelTextStyle: TextStyle(color: Colors.white),
          timeLabelType: TimeLabelType.totalTime,
          barHeight: PlayerCommons.progressBarHeight,
          thumbRadius: PlayerCommons.progressBarThumbInnerRadius,
          thumbGlowRadius: PlayerCommons.progressBarThumbRadius,
          progress: controller.playerState.positionDuration.value,
          total: controller.playerState.duration.value,
          buffered: controller.playerState.bufferedDuration.value,
          onDragStart: (details) {
            // controller.hideTimer?.cancel();
            controller.playerState.isDragging(true);
          },
          onDragEnd: () {
            controller.playerState.isDragging(false);
          },
          onDragUpdate: (details) {
            LoggerUtils.logger.d("进度条改变事件");
          },
          onSeek: (details) {
            controller.seekTo(Duration(seconds: details.inSeconds));
          },
        ),
      );
    });
  }
}
