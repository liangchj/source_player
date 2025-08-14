import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../../widgets/clickable_button_widget.dart';
import '../commons/player_commons.dart';

// 播放倍数ui
class PlayerSpeedUI extends StatefulWidget {
  const PlayerSpeedUI({
    super.key,
    this.bottomSheet = false,
    this.singleHorizontalScroll = false,
  });
  final bool bottomSheet;
  final bool singleHorizontalScroll;

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

    int playSpeedIndex = PlayerCommons.playSpeedList.indexOf(
      controller.playerState.playSpeed.value,
    );
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
    if (!controller.playerState.isFullscreen.value || widget.bottomSheet) {
      return _createList();
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
      child: Center(child: _createList()),
    );
  }

  Widget _createList() {
    return ListViewObserver(
      controller: _listObserverController,
      child: ListView.builder(
        scrollDirection: widget.singleHorizontalScroll ? Axis.horizontal : Axis.vertical,
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: PlayerCommons.playSpeedList.length,
        itemBuilder: (ctx, index) {
          var value = PlayerCommons.playSpeedList[index];
          return Obx(
            () => widget.singleHorizontalScroll ?
            Container(
              decoration: BoxDecoration(
                color: value == controller.playerState.playSpeed.value ? WidgetStyleCommons.primaryColor.withValues(alpha: 0.2) : null,
                //设置四周圆角 角度
                borderRadius: const BorderRadius.all(
                  Radius.circular(WidgetStyleCommons.borderRadius),
                ),
              ),
              child: TextButton(
                onPressed: () {
                  controller.playerState.playSpeed(value);
                },
                child: Text(
                  "${value.toString()}x",
                  style: TextStyle(color: value == controller.playerState.playSpeed.value ? WidgetStyleCommons.primaryColor : controller.playerState.isFullscreen.value
                      ? Colors.white
                      : Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ) : Padding(
              padding: EdgeInsets.symmetric(vertical: WidgetStyleCommons.safeSpace / 6),
              child: ClickableButtonWidget(
                text: "${value.toString()}x",
                textAlign: TextAlign.center,
                activated: value == controller.playerState.playSpeed.value,
                isCard: true,
                showBorder: false,
                unActivatedTextColor: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
                padding: EdgeInsets.symmetric(
                  vertical: WidgetStyleCommons.safeSpace / 2,
                  horizontal: 0,
                ),
                onClick: () {
                  controller.playerState.playSpeed(value);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
