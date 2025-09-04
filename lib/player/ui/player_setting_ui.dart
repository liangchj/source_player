import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/enums/player_fit_enum.dart';
import 'package:source_player/player/ui/player_speed_ui.dart';

import '../../commons/widget_style_commons.dart';
import '../../utils/logger_utils.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../models/bottom_ui_control_item_model.dart';
import '../widgets/build_text_widget.dart';

class PlayerSettingUI extends StatefulWidget {
  const PlayerSettingUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  State<PlayerSettingUI> createState() => _PlayerSettingUIState();
}

class _PlayerSettingUIState extends State<PlayerSettingUI> {
  late PlayerController controller;

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize;
    double screenWidth = MediaQuery.of(context).size.width;
    return controller.playerState.isFullscreen.value && !widget.bottomSheet
        ? Container(
            width: PlayerCommons.settingUIDefaultWidth.clamp(
              screenWidth * 0.3,
              screenWidth * 0.8,
            ),
            height: double.infinity,
            color: PlayerCommons.playerUIBackgroundColor,
            padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
            child: ListView(
              children: [
                _createAspectRatio(),
                _createResourceChapter(),
                _settingItem(
                  "字幕",
                  controller.uiState.settingsUIMap["subtitleList"],
                ),
                _createDanmaku(),
                // _settingItem("倍数", speedList),
                _settingPlayerSpeed(
                  PlayerCommons.settingUIDefaultWidth.clamp(
                    screenWidth * 0.3,
                    screenWidth * 0.8,
                  ),
                  fontSize: fontSize,
                ),
              ],
            ),
          )
        : ListView(
            children: [
              _createAspectRatio(),
              _createResourceChapter(),
              _settingItem(
                "字幕",
                controller.uiState.settingsUIMap["subtitleList"],
              ),
              _createDanmaku(),
              // _settingItem("倍数", speedList),
              _settingPlayerSpeed(screenWidth, fontSize: fontSize),
            ],
          );
  }

  Widget _createAspectRatio() {
    return Obx(() {
      late Object? activated;
      if (controller.playerState.aspectRatio.value == null) {
        activated = controller.playerState.fit.value?.name;
      } else {
        activated = controller.playerState.aspectRatio.value;
      }
      activated ??= "contain";
      return _createSettingItem(
        "画面尺寸",
        Row(
          spacing: WidgetStyleCommons.safeSpace,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: controller.playerState.playerAspectRatioList.map((item) {
            return InkWell(
              onTap: () {
                bool isNumber = item.value is double;
                if (isNumber) {
                  controller.playerState.fit.value = null;
                  controller.playerState.aspectRatio(item.value);
                } else {
                  controller.playerState.aspectRatio.value = null;
                  controller.playerState.fit(
                    PlayerFitEnum.values.firstWhereOrNull(
                          (e) => e.name == item.value,
                        ) ??
                        PlayerFitEnum.contain,
                  );
                }
              },
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.value == activated
                      ? WidgetStyleCommons.primaryColor
                      : (controller.playerState.isFullscreen.value
                            ? PlayerCommons.textColor
                            : Colors.black),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _settingPlayerSpeed(double width, {double? fontSize}) {
    return Padding(
      padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace / 2),
            child: _createTitle("倍数"),
          ),
          SizedBox(
            width: width,
            height: (fontSize ?? 14) + WidgetStyleCommons.safeSpace * 2,
            child: PlayerSpeedUI(
              bottomSheet: true,
              singleHorizontalScroll: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createResourceChapter() {
    return Obx(
      () => controller.playerState.isFullscreen.value
          ? _settingItem(
              "资源章节信息",
              controller.uiState.settingsUIMap["resourceChapterList"],
            )
          : Container(),
    );
  }

  Widget _createDanmaku() {
    return Obx(() {
      var sendDanmaku = controller.fullscreenBottomUIItemList.firstWhereOrNull(
        (item) => item.type == ControlType.sendDanmaku,
      );
      if (sendDanmaku == null || sendDanmaku.visible.value) {
        return _settingItem(
          "弹幕",
          controller.uiState.settingsUIMap["danmakuList"],
        );
      }
      return _settingItem("弹幕", [
        InkWell(
          onTap: () {
            LoggerUtils.logger.d("发送弹幕");
          },
          child: Text("发送弹幕"),
        ),
        ...controller.uiState.settingsUIMap["danmakuList"] ?? [],
      ]);
    });
  }

  Widget _settingItem(String text, List<Widget>? childrenList) {
    if (childrenList == null || childrenList.isEmpty) {
      return Container();
    }
    return _createSettingItem(
      text,
      Row(
        spacing: WidgetStyleCommons.safeSpace,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: childrenList,
      ),
    );
  }

  Widget _createSettingItem(String text, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
            child: _createTitle(text),
          ),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BuildTextWidget(
        text: text,
        style: TextStyle(
          color: controller.playerState.isFullscreen.value
              ? PlayerCommons.textColor.withValues(alpha: 0.8)
              : Colors.black,
          fontSize: PlayerCommons.titleTextSize,
        ),
        edgeInsets: const EdgeInsets.all(0),
      ),
    );
  }
}
