import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../commons/player_commons.dart';
// 播放倍数ui
class PlayerSpeedUI extends StatefulWidget {
  const PlayerSpeedUI({super.key});

  @override
  State<PlayerSpeedUI> createState() => _PlayerSpeedUIState();
}

class _PlayerSpeedUIState extends State<PlayerSpeedUI> {
  late PlayerController controller;
  late final ScrollController _scrollController;
  late ListObserverController _listObserverController;

  @override
  void initState() {
    controller = Get.find<PlayerController>();

    int playSpeedIndex = PlayerCommons.playSpeedList.indexOf(controller.playerState.playSpeed.value);
    if (playSpeedIndex == -1) {
      playSpeedIndex = PlayerCommons.playSpeedList.indexOf(1.0);
      if (playSpeedIndex == -1) {
        playSpeedIndex = 0;
        controller.playerState.playSpeed(PlayerCommons.playSpeedList[0]);
      } else {
        controller.playerState.playSpeed(1.0);
      }
    }

    _scrollController = ScrollController();
    _listObserverController = ListObserverController(
      controller: _scrollController,
    )..initialIndex = playSpeedIndex;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.playerState.isFullscreen.value) {
      return ListViewObserver(
        controller: _listObserverController,
        child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: PlayerCommons.playSpeedList.length,
            itemBuilder: (ctx, index) {
              return Obx(() => _buildDialogSpeedButton(PlayerCommons.playSpeedList[index]));
            }),
      );
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: PlayerCommons.speedSettingUIDefaultWidth.clamp(
        screenWidth * 0.3,
        screenWidth * 0.8,
      ),
      height: double.infinity,
      color: PlayerCommons.playerUIBackgroundColor,
      padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
      child: Center(
        child: ListViewObserver(
          controller: _listObserverController,
          child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: PlayerCommons.playSpeedList.length,
              itemBuilder: (ctx, index) {
                return Obx(() => _buildFullscreenSpeedButton(PlayerCommons.playSpeedList[index]));
              }),
        ),

      ),
    );
  }

  // 一般是竖屏弹出的选择倍速
  Widget _buildDialogSpeedButton(double e) {
    Color fontColor = e == controller.playerState.playSpeed.value
        ? Colors.redAccent
        : Colors.black;
    return ListTile(
      onTap: () {
        controller.playerState.playSpeed(e);
      },
      textColor: fontColor,
      title: Text("${e.toString()}x"),
      trailing: const Icon(Icons.add),
    );
  }

  Widget _buildFullscreenSpeedButton(double e) {
    Color fontColor = e == controller.playerState.playSpeed.value
        ? WidgetStyleCommons.activatedTextColor
        : PlayerCommons.playSpeedTextColor;
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          controller.playerState.playSpeed(e);
        },
        child: Text(
          "${e.toString()}x",
          style: TextStyle(color: fontColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
