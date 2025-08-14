

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../controller/player_controller.dart';

class PlayerScreenshotUI extends GetView<PlayerController> {
  const PlayerScreenshotUI({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        // color: WidgetStyleCommons.iconColor,
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor:
            WidgetStateProperty.all(Colors.black.withValues(alpha: 0.1))),
        icon: Icon(Icons.photo_camera_outlined));
  }
}
