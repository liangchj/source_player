
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
// 顶部UI
class PlayerTopUI extends GetView<PlayerController> {
  const PlayerTopUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 背景渐变效果
      decoration: BoxDecoration(gradient: PlayerCommons.topUILinearGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
              onPressed: () {
                controller.fullscreenUtils.toggleFullScreen();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          // 标题
          Expanded(child: Text(
            "标题",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          // 右边控制栏
        ],
      ),
    );
  }
}