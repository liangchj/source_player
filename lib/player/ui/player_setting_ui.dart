
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';

class PlayerSettingUI extends StatefulWidget {
  const PlayerSettingUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  State<PlayerSettingUI> createState() => _PlayerSettingUIState();
}

class _PlayerSettingUIState extends State<PlayerSettingUI> {
  late PlayerController controller;

  List<Widget> playTypeList = [
    InkWell(
        onTap: () {
          print("自动连播");
        },
        child: Text("自动连播")),
    InkWell(
        onTap: () {
          print("列表循环");
        },
        child: Text("列表循环")),
    InkWell(
        onTap: () {
          print("单集循环");
        },
        child: Text("单集循环")),
    InkWell(
        onTap: () {
          print("播完暂停");
        },
        child: Text("播完暂停")),
  ];

  List<Widget> screenSizeList = [
    InkWell(
        onTap: () {
          print("适应");
        },
        child: Text("适应")),
    InkWell(
        onTap: () {
          print("拉伸");
        },
        child: Text("拉伸")),
    InkWell(
        onTap: () {
          print("填充");
        },
        child: Text("填充")),
    InkWell(
        onTap: () {
          print("16:9");
        },
        child: Text("16:9")),
    InkWell(
        onTap: () {
          print("4:3");
        },
        child: Text("4:3")),
  ];

  List<Widget> subtitleList = [
    InkWell(
        onTap: () {
          print("字幕轨");
        },
        child: Text("字幕轨")),
    InkWell(
        onTap: () {
          print("字幕样式");
        },
        child: Text("字幕样式")),
    InkWell(
        onTap: () {
          print("字幕时间");
        },
        child: Text("字幕时间")),
    ];
  List<Widget> danmakuList = [
    InkWell(
        onTap: () {
          print("弹幕轨");
        },
        child: Text("弹幕轨")),
    InkWell(
        onTap: () {
          print("弹幕源");
        },
        child: Text("弹幕源")),
    InkWell(
        onTap: () {
          print("弹幕时间");
        },
        child: Text("弹幕时间")),
  ];

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return controller.playerState.isFullscreen.value && !widget.bottomSheet ? Container(
      width: PlayerCommons.settingUIDefaultWidth.clamp(
        screenWidth * 0.3,
        screenWidth * 0.8,
      ),
      height: double.infinity,
      color: PlayerCommons.playerUIBackgroundColor,
      padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
      child: ListView(
        children: [
          _settingItem("播放方式", playTypeList),
          _settingItem("画面尺寸", screenSizeList),
          _settingItem("字幕", subtitleList),
          _settingItem("弹幕", danmakuList),
        ],
      ),
    ) : ListView(
      children: [
        _settingItem("播放方式", playTypeList),
        _settingItem("画面尺寸", screenSizeList),
        _settingItem("字幕", subtitleList),
        _settingItem("弹幕", danmakuList),
      ],
    );
  }

  Widget _settingItem(String text, List<Widget> childrenList) {
    return Padding(
      padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment. start,
          children: [
            Padding(padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace / 2), child: _createTitle(text),),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
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
          ]
      ),
    );
  }

  Widget _createTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BuildTextWidget(
          text: text,
          style: TextStyle(
              color: controller.playerState.isFullscreen.value ? PlayerCommons.textColor : Colors.black,
              fontSize: PlayerCommons.titleTextSize),
          edgeInsets: const EdgeInsets.all(0)),
    );
  }
}

/// 文本框Widget
class BuildTextWidget extends StatelessWidget {
  const BuildTextWidget(
      {super.key, required this.text, this.style, this.edgeInsets});
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
