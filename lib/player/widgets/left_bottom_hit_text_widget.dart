

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/controller/player_controller.dart';

class LeftBottomHitTextWidget extends GetView<PlayerController> {
  const LeftBottomHitTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      /*child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: controller.uiState.bottomLeftUIList.map((e) => e).toList(),
      ),*/
    );
  }

}