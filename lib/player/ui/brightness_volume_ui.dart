import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';

enum BrightnessVolumeType { brightness, volume, none }

class BrightnessVolumeUI extends GetView<PlayerController> {
  const BrightnessVolumeUI({
    super.key,
    this.brightnessVolumeType = BrightnessVolumeType.none,
  });
  final BrightnessVolumeType brightnessVolumeType;

  @override
  Widget build(BuildContext context) {
    return brightnessVolumeType == BrightnessVolumeType.none
        ? Container()
        : Center(
            child: UnconstrainedBox(
              child: Container(
                width: PlayerCommons.volumeOrBrightnessUISize.width,
                height: PlayerCommons.volumeOrBrightnessUISize.height,
                decoration: BoxDecoration(
                  color: PlayerCommons.backgroundColor,
                  //设置四周圆角 角度
                  borderRadius: const BorderRadius.all(
                    Radius.circular(WidgetStyleCommons.borderRadius),
                  ),
                ),
                child: Obx(() {
                  List<Widget> uiList = [];
                  if (brightnessVolumeType == BrightnessVolumeType.brightness) {
                    uiList = [
                      const Icon(
                        Icons.brightness_6_rounded,
                        color: WidgetStyleCommons.iconColor,
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                      Text(
                        "${controller.playerState.brightness}%",
                        style: TextStyle(color: PlayerCommons.textColor),
                      ),
                    ];
                  } else if (brightnessVolumeType ==
                      BrightnessVolumeType.volume) {
                    uiList = [
                      const Icon(
                        Icons.volume_up_rounded,
                        color: WidgetStyleCommons.iconColor,
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                      Text(
                        "${controller.playerState.volume}%",
                        style: const TextStyle(color: PlayerCommons.textColor),
                      ),
                    ];
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: uiList.map((e) => e).toList(),
                  );
                }),
              ),
            ),
          );
  }
}
