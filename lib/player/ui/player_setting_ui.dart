import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/ui/player_speed_ui.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../enums/player_ui_key_enum.dart';
import '../models/buttom_ui_control_item_model.dart';
import '../utils/bottom_sheet_utils.dart';

class PlayerSettingUI extends StatefulWidget {
  const PlayerSettingUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  State<PlayerSettingUI> createState() => _PlayerSettingUIState();
}

class _PlayerSettingUIState extends State<PlayerSettingUI> {
  late PlayerController controller;


  List<Widget> aspectRatioList = [
  ];

  List<Widget> chapterList = [
    InkWell(
      onTap: () {
        print("章节列表");
      },
      child: Text("章节列表"),
    ),
  ];

  List<Widget> subtitleList = [
    InkWell(
      onTap: () {
        print("字幕轨");
      },
      child: Text("字幕轨"),
    ),
    InkWell(
      onTap: () {
        print("字幕样式");
      },
      child: Text("字幕样式"),
    ),
    InkWell(
      onTap: () {
        print("字幕时间");
      },
      child: Text("字幕时间"),
    ),
  ];
  List<Widget> danmakuList = [
    InkWell(
      onTap: () {
        print("弹幕轨");
      },
      child: Text("弹幕轨"),
    ),
    InkWell(
      onTap: () {
        print("弹幕源");
      },
      child: Text("弹幕源"),
    ),
    InkWell(
      onTap: () {
        print("弹幕时间");
      },
      child: Text("弹幕时间"),
    ),
  ];

  List<Widget> speedList = [];

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    controller.playerState.aspectRatioMap.forEach((key, value) {
      aspectRatioList.add(
        Obx(() => InkWell(
          onTap: () {
            controller.playerState.aspectRatio(value);
          },
          child: Text(key, style: TextStyle(color: value == controller.playerState.aspectRatio.value ? WidgetStyleCommons.mainColor : (
              controller.playerState.isFullscreen.value ?
              PlayerCommons.textColor : Colors.black))),
        )),
      );
    });

    speedList.add(
      InkWell(
        onTap: () {
          Get.closeAllBottomSheets();
          if (controller.playerState.isFullscreen.value) {
            controller.showUIByKeyList([PlayerUIKeyEnum.speedSettingUI.name]);
          } else {
            BottomSheetUtils.openBottomSheet(
              PlayerSpeedUI(
                bottomSheet: true,
              ),
            );
          }
        },
        child: Text("播放倍数"),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                _settingItem("画面尺寸", aspectRatioList),
                _createChapter(),
                _settingItem("字幕", subtitleList),
                _createDanmaku(),
                _settingItem("倍数", speedList),
              ],
            ),
          )
        : ListView(
            children: [
              _settingItem("画面尺寸", aspectRatioList),
              _createChapter(),
              _settingItem("字幕", subtitleList),
              _createDanmaku(),
              _settingItem("倍数", speedList),
            ],
          );
  }

  Widget _createChapter() {
    return Obx(() {
      if (!controller.playerState.isFullscreen.value) {
        return Container();
      }
      var chapter = controller.fullscreenBottomUIItemList.firstWhereOrNull(
        (item) => item.type == ControlType.chapter,
      );
      if (chapter == null || chapter.visible.value) {
        return Container();
      }
      return _settingItem("章节信息", chapterList);
    });
  }

  Widget _createDanmaku() {
    return Obx(() {
      var sendDanmaku = controller.fullscreenBottomUIItemList.firstWhereOrNull(
        (item) => item.type == ControlType.sendDanmaku,
      );
      if (sendDanmaku == null || sendDanmaku.visible.value) {
        return _settingItem("弹幕", danmakuList);
      }
      return _settingItem("弹幕", [
        InkWell(
          onTap: () {
            print("发送弹幕");
          },
          child: Text("发送弹幕"),
        ),
        ...danmakuList,
      ]);
    });
  }

  Widget _settingItem(String text, List<Widget> childrenList) {
    return Padding(
      padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace / 2),
            child: _createTitle(text),
          ),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: WidgetStyleCommons.safeSpace,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: childrenList,
              ),
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
              ? PlayerCommons.textColor
              : Colors.black,
          fontSize: PlayerCommons.titleTextSize,
        ),
        edgeInsets: const EdgeInsets.all(0),
      ),
    );
  }
}

/// 文本框Widget
class BuildTextWidget extends StatelessWidget {
  const BuildTextWidget({
    super.key,
    required this.text,
    this.style,
    this.edgeInsets,
  });
  final String text;
  final TextStyle? style;
  final EdgeInsets? edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets ?? const EdgeInsets.only(left: 5, right: 5),
      child: Text(text, style: style ?? const TextStyle(color: Colors.white)),
    );
  }
}
