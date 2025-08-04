
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

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

      },
      onVerticalDragUpdate: (DragUpdateDetails details) {

      },
      onVerticalDragEnd: (DragEndDetails details) {

      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

}
