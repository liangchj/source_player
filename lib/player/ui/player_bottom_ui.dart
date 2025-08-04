import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../../commons/widget_style_commons.dart';
import '../../utils/logger_utils.dart';
import '../commons/player_commons.dart';
import '../enums/player_ui_key_enum.dart';
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
        child: _buildHorizontalScreenBottomUI(),
        // child: Obx(() => controller.playerState.isFullscreen.value ? _buildHorizontalScreenBottomUI() : _buildVerticalScreenBottomUI()),
      ),
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
        _buildPlayPositionDuration(),
        // 进度条
        _buildProgressBar(),

        // 总时长
        _buildTotalDuration(),

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

  /// 横屏底部UI
  Widget _buildHorizontalScreenBottomUI() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
          ),
          child: _buildProgressBar(),
        ),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 播放时长
            // _buildPlayPositionDuration(padding: EdgeInsets.all(0)),
            // 进度条
            _buildProgressBar(),
            // 总时长
            // _buildTotalDuration(),
          ],
        ),*/
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlayPause(),
            // 下一个视频
            // 下一个视频按钮
            /*Obx(() =>
            controller.netResourceDetailPlayController.haveNext.value
                ? IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                onPressed: () => controller.playNext(),
                icon: UIConstants.nextPlayIcon)
                : Container()),*/

            // 弹幕开关

            // // 弹幕设置
            // Expanded(child: Container()),

            // 选集
            // if (controller
            //     .playConfigOptions.resourceChapterList.isNotEmpty &&
            //     controller.playConfigOptions.resourceChapterList.length > 1)
            /*TextButton(
              onPressed: () => controller.uiControl.onlyShowUIByKeyList(
                  [PlayerUIKeyEnum.chapterListUI.name]),
              child: const Text(
                "选集",
                style: TextStyle(color: UIConstants.textColor),
              ),
            ),*/

            // 倍数
            TextButton(
              onPressed: () => controller.showUIByKeyList([
                PlayerUIKeyEnum.speedSettingUI.name,
              ]),
              child: const Text("倍数"),
            ),

            // 只有全屏时没有退出全屏按钮
            if (!controller.onlyFullscreen)
              Obx(
                () => controller.playerState.isFullscreen.value
                    ? IconButton(
                        onPressed: () {
                          controller.fullscreenUtils.toggleFullscreen(
                            context: context,
                          );
                        },
                        icon: PlayerCommons.exitFullscreenIcon,
                      )
                    : Container(),
              ),
          ],
        ),
      ],
    );
  }

  // 播放、暂停按钮
  Widget _buildPlayPause() {
    return IconButton(
      onPressed: () => controller.playOrPause(),
      icon: Obx(() {
        var isFinished = controller.playerState.isFinished.value;
        var isPlaying = controller.playerState.isPlaying.value;
        return Icon(
          isFinished
              ? Icons.play_arrow
              : (isPlaying ? Icons.pause : Icons.play_arrow),
        );
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
      /*if (!controller.uiOptions.bottomUI.visible.value) {
        return Container();
      }*/
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
            // 记录拖动结束前播放状态
            controller.playerState.beforeSeekToIsPlaying =
                controller.player.value?.playing ?? false;
            if (controller.playerState.isPlaying.value) {
              controller.pause();
            }
            controller.playerState.isDragging(false);
          },
          onDragUpdate: (details) {
            LoggerUtils.logger.d("进度条改变事件");
          },
          onSeek: (details) async {
            controller.playerState.isSeeking(true);
            await controller.seekTo(Duration(seconds: details.inSeconds));

            if (controller.playerState.beforeSeekToIsPlaying) {
              controller.playerState.beforeSeekToIsPlaying = false;
              controller.playerState.isSeeking(false);
              await controller.play();
            }
          },
        ),
      );
    });
  }
}
