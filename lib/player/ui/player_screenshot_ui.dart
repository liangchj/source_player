

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/player_controller.dart';

class PlayerScreenshotUI extends GetView<PlayerController> {
  const PlayerScreenshotUI({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor:
            WidgetStateProperty.all(Colors.white.withOpacity(0.1))),
        icon: Icon(Icons.photo_camera_outlined));
  }
}
