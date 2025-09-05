import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import 'background_event_ui.dart';

class PlayerUI extends StatefulWidget {
  const PlayerUI({super.key});

  @override
  State<PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<PlayerUI> with TickerProviderStateMixin {
  late PlayerController controller;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    controller.updateAnimateController(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在这里执行你的构建之后的操作
      controller.cancelHideTimer();
      if (!controller.uiState.uiLocked.value) {
        controller.onlyShowUIByKeyList(
          controller.uiState.touchBackgroundShowUIKeyList,
        );
        controller.cancelAndRestartTimer();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(
                  () =>
                      controller.danmakuState.danmakuView.value ?? Container(),
                ),
              ),
              /*Positioned.fill(
                child: Obx(
                  () => controller.danmakuState.isVisible.value
                      ? controller.danmakuState.danmakuView.value ?? Container()
                      : Container(),
                ),
              ),*/
              const Positioned.fill(child: BackgroundEventUI()),

              // 顶部UI（资源信息）
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: Obx(
                  () => controller.uiState.topUI.widgetCallback(
                    controller.uiState.topUI,
                  ),
                ),
              ),

              // 底部UI（进度和控制信息）
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.bottomUI.widgetCallback(
                    controller.uiState.bottomUI,
                  ),
                ),
              ),

              Obx(
                () => Positioned(
                  left: 0,
                  right: 0,
                  bottom: controller.uiState.bottomUI.visible.value
                      ? controller.uiState.bottomUIHeight.value
                      : 0,
                  child: Obx(
                    () => controller.uiState.restartUI.widgetCallback(
                      controller.uiState.restartUI,
                    ),
                  ),
                ),
              ),

              Obx(
                () => Positioned(
                  left: 0,
                  right: 0,
                  bottom:
                      (controller.uiState.bottomUI.visible.value
                          ? controller.uiState.bottomUIHeight.value
                          : 0) +
                      (controller.uiState.restartUI.visible.value ? 42 : 0),
                  child: Obx(
                    () => controller.uiState.leftBottomHitUI.widgetCallback(
                      controller.uiState.leftBottomHitUI,
                    ),
                  ),
                ),
              ),

              Center(
                child: Obx(
                  () => controller.playerState.isInitialized.value
                      ? Container()
                      : CircularProgressIndicator(color: Colors.white),
                ),
              ),

              Center(
                child: Obx(
                  () => controller.playerState.isBuffering.value
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )
                      : Container(),
                ),
              ),

              // 居中进度
              Center(
                child: Obx(
                  () => controller.uiState.centerProgressUI.widgetCallback(
                    controller.uiState.centerProgressUI,
                  ),
                ),
              ),

              // 左边UI （锁按钮）
              Align(
                alignment: Alignment.centerLeft,
                child: Obx(
                  () => controller.uiState.lockCtrUI.widgetCallback(
                    controller.uiState.lockCtrUI,
                  ),
                ),
              ),

              // 右边设置（全屏情况显示）
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.settingUI.widgetCallback(
                    controller.uiState.settingUI,
                  ),
                ),
              ),
              // 右边弹幕设置（全屏情况显示）
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.danmakuSettingUI.widgetCallback(
                    controller.uiState.danmakuSettingUI,
                  ),
                ),
              ),

              // 右边播放速度设置（全屏情况显示）
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.speedSettingUI.widgetCallback(
                    controller.uiState.speedSettingUI,
                  ),
                ),
              ),

              // 右边资源来源（全屏情况显示）
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.sourceUI.widgetCallback(
                    controller.uiState.sourceUI,
                  ),
                ),
              ),

              // 右边章节列表（全屏情况显示）
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => controller.uiState.chapterListUI.widgetCallback(
                    controller.uiState.chapterListUI,
                  ),
                ),
              ),

              // 右边UI（截屏按钮）
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => controller.uiState.screenshotCtrUI.widgetCallback(
                    controller.uiState.screenshotCtrUI,
                  ),
                ),
              ),

              // 居中音量
              Center(
                child: Obx(
                  () =>
                      controller.uiState.centerVolumeUI.ui.value ?? Container(),
                ),
              ),
              // 居中亮度
              Center(
                child: Obx(
                  () =>
                      controller.uiState.centerBrightnessUI.ui.value ??
                      Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
