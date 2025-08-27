import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../widgets/build_text_widget.dart';

class DanmakuSettingUI extends GetView<PlayerController> {
  const DanmakuSettingUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    List<Widget> listWidget = [
      _settingList(),
      Padding(
        padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace / 2),
      ),
      // 屏蔽类型
      Column(
        children: [
          _createTitle("屏蔽类型"),
          FractionallySizedBox(
            widthFactor: 1.0,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: WidgetStyleCommons.safeSpace, // 主轴(水平)方向间距
              runSpacing: WidgetStyleCommons.safeSpace, // 纵轴（垂直）方向间距
              verticalDirection: VerticalDirection.down,
              alignment: WrapAlignment.spaceBetween, //
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...controller.danmakuState.danmakuFilterTypeList.map(
                  (filterType) => Obx(
                    () => InkWell(
                      onTap: () => filterType.filter(!filterType.filter.value),
                      child: Column(
                        children: [
                          filterType.openImageIcon,
                          Text(
                            filterType.chName,
                            style: TextStyle(
                              fontSize: PlayerCommons.titleTextSize,
                              color: filterType.filter.value
                                  ? WidgetStyleCommons.primaryColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace)),
      // 时间调整
      Column(
        children: [
          _createTitle("时间调整（秒）"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    controller.danmakuState.uiShowAdjustTime.value =
                        controller.danmakuState.uiShowAdjustTime.value - 0.5,
                icon: Icon(
                  Icons.remove_circle_rounded,
                  color:themeData.primaryColor,
                ),
              ),
              Container(
                width: 80,
                padding: EdgeInsets.symmetric(
                  horizontal: WidgetStyleCommons.safeSpace,
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.danmakuState.uiShowAdjustTime.toStringAsFixed(
                        1,
                      ),
                      style: TextStyle(
                        fontSize: PlayerCommons.titleTextSize,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    controller.danmakuState.uiShowAdjustTime.value =
                        controller.danmakuState.uiShowAdjustTime.value + 0.5,
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: themeData.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.danmakuState.adjustTime.value =
                    controller.danmakuState.uiShowAdjustTime.value;
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WidgetStyleCommons.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  WidgetStyleCommons.primaryColor,
                ),
              ),
              child: const Text(
                "同步弹幕时间",
                style: TextStyle(
                  fontSize: PlayerCommons.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace)),
      // 弹幕屏蔽词
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_createTitle("弹幕屏蔽词")],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WidgetStyleCommons.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  WidgetStyleCommons.primaryColor,
                ),
              ),
              child: const Text(
                "弹幕屏蔽管理",
                style: TextStyle(
                  fontSize: PlayerCommons.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace)),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_createTitle("弹幕列表")],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WidgetStyleCommons.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  WidgetStyleCommons.primaryColor,
                ),
              ),
              child: const Text(
                "查看弹幕列表",
                style: TextStyle(
                  fontSize: PlayerCommons.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    return controller.playerState.isFullscreen.value && !bottomSheet
        ? Container(
            width: PlayerCommons.danmakuSettingUIDefaultWidth.clamp(
              screenWidth * 0.3,
              screenWidth * 0.8,
            ),
            height: double.infinity,
            color: PlayerCommons.playerUIBackgroundColor,
            padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
            child: ListView(children: listWidget),
          )
        : ListView(children: listWidget);
  }

  // 弹幕设置
  Widget _settingList() {
    return Column(
      children: [
        _createTitle("弹幕设置"),
        Column(
          children: [
            // 弹幕不透明度设置
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace / 2,
              ),
              child: _danmakuOpacitySetting(),
            ),
            // 弹幕显示区域设置
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace / 2,
              ),
              child: _danmakuDisplayAreaSetting(),
            ),
            // 弹幕字号设置
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace / 2,
              ),
              child: _danmakuFontSizeSetting(),
            ),
            // 弹幕速度设置
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace / 2,
              ),
              child: _danmakuSpeedSetting(),
            ),
          ],
        ),
      ],
    );
  }

  /// 弹幕不透明度设置
  Widget _danmakuOpacitySetting() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左边文字说明
          _leftDescText("不透明度"),

          // 中间进度指示器
          Expanded(
            child: Slider(
              value: controller.danmakuState.danmakuAlphaRatio.value.ratio,
              min: controller.danmakuState.danmakuAlphaRatio.value.min,
              max: controller.danmakuState.danmakuAlphaRatio.value.max,
              onChanged: (value) {
                controller.danmakuState.danmakuAlphaRatio.value = controller
                    .danmakuState
                    .danmakuAlphaRatio
                    .value
                    .copyWith(ratio: value.truncateToDouble());
              },
            ),
          ),

          // 右边进度提示
          _rightTipText("${controller.danmakuState.danmakuAlphaRatio.value.ratio}%"),
        ],
      ),
    );
  }

  /// 弹幕显示区域设置
  Widget _danmakuDisplayAreaSetting() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左边文字说明
          _leftDescText("显示区域"),

          // 中间进度指示器
          Expanded(
            child: Slider(
              value: controller.danmakuState.danmakuArea.value.areaIndex
                  .toDouble(),
              min: 0,
              max:
                  controller
                      .danmakuState
                      .danmakuArea
                      .value
                      .danmakuAreaItemList
                      .length -
                  1,
              divisions:
                  controller
                      .danmakuState
                      .danmakuArea
                      .value
                      .danmakuAreaItemList
                      .length -
                  1,
              onChanged: (value) {
                controller.danmakuState.danmakuArea.value = controller
                    .danmakuState
                    .danmakuArea
                    .value
                    .copyWith(areaIndex: value.toInt());
              },
            ),
          ),
          _rightTipText(
            controller
                .danmakuState
                .danmakuArea
                .value
                .danmakuAreaItemList[controller
                    .danmakuState
                    .danmakuArea
                    .value
                    .areaIndex]
                .name,
          ),
        ],
      ),
    );
  }

  /// 弹幕字号设置
  Widget _danmakuFontSizeSetting() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左边文字说明
          _leftDescText("弹幕字号"),

          // 中间进度指示器
          Expanded(
            child: Slider(
              value: controller.danmakuState.danmakuFontSize.value.ratio,
              min: controller.danmakuState.danmakuFontSize.value.min,
              max: controller.danmakuState.danmakuFontSize.value.max,
              onChanged: (value) {
                controller.danmakuState.danmakuFontSize.value = controller
                    .danmakuState
                    .danmakuFontSize
                    .value
                    .copyWith(ratio: value.truncateToDouble());
              },
            ),
          ),

          // 右边进度提示
          _rightTipText(
            "${controller.danmakuState.danmakuFontSize.value.ratio}%",
          ),
        ],
      ),
    );
  }

  /// 弹幕速度设置
  Widget _danmakuSpeedSetting() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左边文字说明
          _leftDescText("弹幕速度"),

          // 中间进度指示器
          Expanded(
            child: Slider(
              value: controller.danmakuState.danmakuSpeed.value.speed,
              min: controller.danmakuState.danmakuSpeed.value.min,
              max: controller.danmakuState.danmakuSpeed.value.max,
              onChanged: (value) {
                controller.danmakuState.danmakuSpeed.value = controller
                    .danmakuState
                    .danmakuSpeed
                    .value
                    .copyWith(speed: value.truncateToDouble());
              },
            ),
          ),

          // 右边进度提示
          _rightTipText("${controller.danmakuState.danmakuSpeed.value.speed}秒"),
        ],
      ),
    );
  }

  // 左边描述文字
  Widget _leftDescText(String text) {
    return Text(
      text,
      style: TextStyle(
        // color: PlayerCommons.textColor,
        fontSize: PlayerCommons.titleTextSize,
      ),
      strutStyle: const StrutStyle(forceStrutHeight: true),
    );
  }

  // 右边提示文字
  Widget _rightTipText(String text) {
    return Stack(
      children: [
        const Text(
          "占位符",
          style: TextStyle(
            fontSize: PlayerCommons.titleTextSize,
            color: Color.fromARGB(0, 0, 0, 0),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            // color: PlayerCommons.textColor,
            fontSize: PlayerCommons.titleTextSize,
          ),
          strutStyle: const StrutStyle(forceStrutHeight: true),
        ),
      ],
    );
  }

  Widget _createTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BuildTextWidget(
        text: text,
        style: const TextStyle(
          // color: PlayerCommons.textColor,
          fontSize: PlayerCommons.titleTextSize,
        ),
        edgeInsets: const EdgeInsets.all(0),
      ),
    );
  }
}
