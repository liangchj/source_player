
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';
import 'package:source_player/utils/logger_utils.dart';

class BackgroundEventUI extends GetView<PlayerController> {
  const BackgroundEventUI({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleBackground(),
      onHorizontalDragStart: (DragStartDetails details) {

      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {

      },
      onHorizontalDragEnd: (DragEndDetails details) {

      },
      onVerticalDragStart: (DragStartDetails details) {
        if (!controller.uiState.uiLocked.value) {
          LoggerUtils.logger.d(
              "滑动屏幕 开始拖动 纵向: $details, ${details.globalPosition}, ${details.localPosition}");
          controller.volumeOrBrightnessOnVerticalDragStart(details);
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        if (!controller.uiState.uiLocked.value) {
          LoggerUtils.logger.d(
              "滑动屏幕 拖动中 纵向: $details, ${details.globalPosition}, ${details.localPosition}, ${details.delta}");
          controller.volumeOrBrightnessOnVerticalDragUpdate(context, details);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        if (!controller.uiState.uiLocked.value) {
          LoggerUtils.logger.d("滑动屏幕 拖动结束 纵向: $details");
          controller.volumeOrBrightnessOnVerticalDragEnd();
        }
        print("滑动结束");
      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

}
