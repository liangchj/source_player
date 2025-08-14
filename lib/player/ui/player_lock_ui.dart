import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../controller/player_controller.dart';

class PlayerLockUI extends GetView<PlayerController> {
  const PlayerLockUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        // color: WidgetStyleCommons.iconColor,
        onPressed: () {
          controller.uiState.uiLocked(!controller.uiState.uiLocked.value);
          if (controller.uiState.uiLocked.value) {
            controller.showUIByKeyList(["lockCtrUI"]);
          } else {
            controller.showUIByKeyList(controller.uiState.touchBackgroundShowUIKeyList);
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.black.withValues(alpha: 0.1),
          ),
        ),
        icon: Icon(
          controller.uiState.uiLocked.value
              ? Icons.lock_clock_rounded
              : Icons.lock_open_rounded,
        ),
      ),
    );
  }
}
