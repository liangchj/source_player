import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/utils/time_format_utils.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';

class CenterPlayProgressUI extends GetView<PlayerController> {
  const CenterPlayProgressUI({super.key});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: PlayerCommons.playProgressUISize.width,
        height: PlayerCommons.playProgressUISize.height,
        decoration: BoxDecoration(
          color: PlayerCommons.backgroundColor,
          //设置四周圆角 角度
          borderRadius: const BorderRadius.all(
            Radius.circular(WidgetStyleCommons.borderRadius),
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${TimeFormatUtils.durationToMinuteAndSecond(Duration(seconds: controller.playerState.draggingSecond.value.abs() > 0 ? controller.playerState.dragProgressPositionDuration.inSeconds + controller.playerState.draggingSecond.value : 0))}/${TimeFormatUtils.durationToMinuteAndSecond(controller.playerState.duration.value)}",
                style: const TextStyle(color: PlayerCommons.textColor),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              Text(
                "${controller.playerState.draggingSecond}秒",
                style: const TextStyle(color: PlayerCommons.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
